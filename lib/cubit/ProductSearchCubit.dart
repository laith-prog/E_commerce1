import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductSearchState {
  final bool isLoading;
  final List<dynamic> products;
  final String error;
  final bool hasMore;

  ProductSearchState({
    this.isLoading = false,
    this.products = const [],
    this.error = '',
    this.hasMore = true, // Indicates if there are more products to load
  });
}

class ProductSearchCubit extends Cubit<ProductSearchState> {
  int currentPage = 1; // Track the current page
  final int limit = 10; // Number of products per page

  ProductSearchCubit() : super(ProductSearchState());

  void searchProducts(String query, {bool isLoadMore = false}) async {
    if (!isLoadMore) {
      // Reset page and products if it's a new search
      currentPage = 1;
      emit(ProductSearchState(isLoading: true));
    } else {
      emit(ProductSearchState(isLoading: true, products: state.products));
    }

    try {
      final response = await http.get(
        Uri.parse(
          'http://10.0.2.2:8000/api/products/search?query=$query&page=$currentPage&limit=$limit',
        ),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> newProducts = data['data'];
        bool hasMore = newProducts.length == limit; // If we received fewer than the limit, no more products

        // If it's not a "load more", replace the products list
        if (!isLoadMore) {
          emit(ProductSearchState(
            isLoading: false,
            products: newProducts,
            hasMore: hasMore,
          ));
        } else {
          // Otherwise, append to the existing list
          emit(ProductSearchState(
            isLoading: false,
            products: [...state.products, ...newProducts],
            hasMore: hasMore,
          ));
        }

        // Increment the current page for the next fetch
        if (hasMore) {
          currentPage++;
        }
      } else {
        emit(ProductSearchState(
            isLoading: false, error: 'Failed to load products'));
      }
    } catch (e) {
      emit(ProductSearchState(isLoading: false, error: 'Error: $e'));
    }
  }
}
