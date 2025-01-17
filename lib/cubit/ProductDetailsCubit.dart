import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductDetailsState {
  final bool isLoading;
  final bool isSuccess;
  final String message;
  final Map<String, dynamic>? productDetails;

  ProductDetailsState({
    this.isLoading = false,
    this.isSuccess = false,
    this.message = '',
    this.productDetails,
  });
}

class ProductDetailsCubit extends Cubit<ProductDetailsState> {
  ProductDetailsCubit() : super(ProductDetailsState());

  Future<void> fetchProductDetails(String productId) async {
    emit(ProductDetailsState(isLoading: true));

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/products/id/$productId'), // Replace with your API URL
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        emit(ProductDetailsState(
          isSuccess: true,
          productDetails: data,
          message: 'Product details loaded successfully',
        ));
      } else {
        emit(ProductDetailsState(message: 'Failed to load product details'));
      }
    } catch (e) {
      emit(ProductDetailsState(message: 'Error: $e'));
    }
  }
}
