import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StoreState {
  final bool isLoading;
  final bool isSuccess;
  final String message;
  final Map<String, dynamic>? store;
  final List<dynamic> products;

  StoreState({
    this.isLoading = false,
    this.isSuccess = false,
    this.message = '',
    this.store,
    this.products = const [],
  });

  StoreState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? message,
    Map<String, dynamic>? store,
    List<dynamic>? products,
  }) {
    return StoreState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      message: message ?? this.message,
      store: store ?? this.store,
      products: products ?? this.products,
    );
  }
}
class StoreCubit extends Cubit<StoreState> {
  int currentPage = 1; // Track current page for pagination
  bool hasMoreProducts = true; // Flag to check if more products are available
  List<dynamic> allProducts = []; // Store all products across pages

  StoreCubit() : super(StoreState());

  // Fetch store details with paginated products
  Future<void> fetchStoreDetails(String storeId, {bool isLoadMore = false}) async {
    if (isLoadMore && !hasMoreProducts) {
      return; // If no more products are available, don't fetch
    }

    try {
      emit(state.copyWith(isLoading: true));

      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/stores/id/$storeId?page=$currentPage'), // Update URL for pagination
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final store = data['store'];
        final products = data['products']['data']; // Paginated products are under 'data'
        final totalProducts = data['products']['total']; // Total number of products

        // If we're loading more, append the products to the existing list
        if (isLoadMore) {
          allProducts.addAll(products);
        } else {
          allProducts = products; // Reset the list when fetching first page
        }

        hasMoreProducts = allProducts.length < totalProducts;

        emit(state.copyWith(
          isLoading: false,
          isSuccess: true,
          store: store,
          products: allProducts,
        ));

        if (isLoadMore) {
          currentPage++; // Increment page when loading more
        }
      } else {
        emit(state.copyWith(
          isLoading: false,
          isSuccess: false,
          message: 'Failed to load store details',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        isSuccess: false,
        message: e.toString(),
      ));
    }
  }
}