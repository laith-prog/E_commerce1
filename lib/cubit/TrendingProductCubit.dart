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
  ProductsCubit() : super(ProductsState());

  Future<void> fetchAllProducts() async {
    emit(state.copyWith(isLoading: true));

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/products'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        emit(state.copyWith(
          isSuccess: true,
          allProducts: data['data'],
          message: 'All products loaded successfully',
        ));
      } else {
        emit(state.copyWith(message: 'Failed to load all products'));
      }
    } catch (e) {
      emit(state.copyWith(message: 'Error: $e'));
    }
  }

  // Fetch trending and best-selling products from the API
  Future<void> fetchProducts() async {
    emit(ProductsState(isLoading: true));

    try {
      final trendingResponse = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/products/trending'), // Replace with your API URL
      );
      final bestSellingResponse = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/products/most-selling'), // Replace with your API URL
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
