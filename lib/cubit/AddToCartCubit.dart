import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AddToCartState {
  final bool isLoading;
  final bool isSuccess;
  final String message;

  AddToCartState({
    this.isLoading = false,
    this.isSuccess = false,
    this.message = '',
  });
}

class AddToCartCubit extends Cubit<AddToCartState> {
  AddToCartCubit() : super(AddToCartState());

  // Function to retrieve token from SharedPreferences
  Future<String> _getAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ?? '';  // Return token or empty string if not found
  }

  Future<void> addToCart(String productId, int quantity) async {
    emit(AddToCartState(isLoading: true));

    try {
      // Get the token from SharedPreferences
      String token = await _getAuthToken();

      if (token.isEmpty) {
        emit(AddToCartState(message: 'No authentication token found'));
        return;
      }

      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/cart/add'),  // Replace with your API URL
        headers: {
          'Authorization': 'Bearer $token',  // Add the Bearer token for authentication
        },
        body: {
          'product_id': productId,
          'quantity': quantity.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        emit(AddToCartState(
          isSuccess: true,
          message: data['message'] ?? 'Product added to cart successfully',
        ));
      } else {
        final data = jsonDecode(response.body);
        emit(AddToCartState(message: data['message'] ?? 'Failed to add product to cart'));
      }
    } catch (e) {
      emit(AddToCartState(message: 'Error: $e'));
    }
  }
}
