import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
class ProductsState {
  final bool isLoading;
  final bool isSuccess;
  final String message;
  final List<dynamic>? trendingProducts;
  final List<dynamic>? bestSellingProducts;
  final List<dynamic>? allProducts; // Added this line

  ProductsState({
    this.isLoading = false,
    this.isSuccess = false,
    this.message = '',
    this.trendingProducts,
    this.bestSellingProducts,
    this.allProducts, // Added this line
  });
  ProductsState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? message,
    List<dynamic>? trendingProducts,
    List<dynamic>? bestSellingProducts,
    List<dynamic>? allProducts,
  }) {
    return ProductsState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      message: message ?? this.message,
      trendingProducts: trendingProducts ?? this.trendingProducts,
      bestSellingProducts: bestSellingProducts ?? this.bestSellingProducts,
      allProducts: allProducts ?? this.allProducts,
    );
  }
}

class ProductsCubit extends Cubit<ProductsState> {
  int _currentPage = 1; // Track the current page
  bool _hasMoreProducts = true; // Flag to check if there are more products
  final int _perPage = 10; // Number of products per page

  ProductsCubit() : super(ProductsState());

  Future<void> fetchAllProducts({bool isPaginated = false}) async {
    if (isPaginated) {
      // Increment or decrement the page number when paginating
      _currentPage++;
    } else {
      // Reset the page to 1 when initially fetching products
      _currentPage = 1;
    }

    emit(state.copyWith(isLoading: true, message: '', allProducts: isPaginated ? state.allProducts : []));

    try {
      final response = await http.get(
        Uri.parse('http://192.168.45.88:8000/api/products?page=$_currentPage'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Check if there is more data to load
        if (data['data'] != null && data['data'] is List) {
          final newProducts = List.from(state.allProducts ?? [])
            ..addAll(data['data']);

          emit(state.copyWith(
            isLoading: false,
            isSuccess: true,
            allProducts: newProducts,
            message: 'Products loaded successfully',
          ));

          _hasMoreProducts = data['data'].length == _perPage; // Check if there are more pages
        } else {
          emit(state.copyWith(
            isLoading: false,
            message: 'Unexpected API response structure',
          ));
        }
      } else {
        emit(state.copyWith(
          isLoading: false,
          message: 'Failed to load products: ${response.reasonPhrase}',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        message: 'Error: $e',
      ));
    }
  }

  bool get hasMoreProducts => _hasMoreProducts;
  int get currentPage => _currentPage;
  // Fetch trending and best-selling products from the API
  Future<void> fetchProducts() async {
    emit(ProductsState(isLoading: true));

    try {
      final trendingResponse = await http.get(
        Uri.parse('http://192.168.45.88:8000/api/products/trending'), // Replace with your API URL
      );
      final bestSellingResponse = await http.get(
        Uri.parse('http://192.168.45.88:8000/api/products/most-selling'), // Replace with your API URL
      );

      if (trendingResponse.statusCode == 200 && bestSellingResponse.statusCode == 200) {
        final trendingData = jsonDecode(trendingResponse.body);
        final bestSellingData = jsonDecode(bestSellingResponse.body);

        emit(ProductsState(
          isSuccess: true,
          trendingProducts: trendingData['data'], // Assuming API returns products in 'data' field
          bestSellingProducts: bestSellingData['data'],
          message: 'Products loaded successfully',
        ));
      } else {
        emit(ProductsState(message: 'Failed to load products'));
      }
    } catch (e) {
      emit(ProductsState(message: 'Error: $e'));
    }
  }
}
