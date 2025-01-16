import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(CartState.initial());

  Future<String> _getAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ?? '';  // Return token or empty string if not found
  }

  Future<void> fetchCart() async {
    try {

      String token = await _getAuthToken();

      if (token.isEmpty) {
        emit(CartState.failure('No authentication token found'));
        return;
      }
      emit(CartState.loading());


      final response = await http.get(Uri.parse('http://10.0.2.2:8000/api/cart'),
        headers: {
        'Authorization': 'Bearer $token',  // Add the Bearer token for authentication
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        emit(CartState.success(data['products']));
      } else {
        emit(CartState.failure('Failed to load cart'));
      }
    } catch (e) {
      emit(CartState.failure(e.toString()));
    }
  }
}

class CartState {
  final bool isLoading;
  final List<dynamic> products;
  final String message;

  CartState({required this.isLoading, required this.products, required this.message});

  factory CartState.initial() => CartState(isLoading: false, products: [], message: '');

  factory CartState.loading() => CartState(isLoading: true, products: [], message: '');

  factory CartState.success(List<dynamic> products) => CartState(isLoading: false, products: products, message: '');

  factory CartState.failure(String message) => CartState(isLoading: false, products: [], message: message);
}
