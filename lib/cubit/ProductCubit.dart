import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductsState {
  final bool isLoading;
  final bool isSuccess;
  final String message;
  final List<dynamic>? trendingProducts;
  final List<dynamic>? bestSellingProducts;

  ProductsState({
    this.isLoading = false,
    this.isSuccess = false,
    this.message = '',
    this.trendingProducts,
    this.bestSellingProducts,
  });
}

class ProductsCubit extends Cubit<ProductsState> {
  ProductsCubit() : super(ProductsState());

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
