import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

abstract class CartState {}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final Map<String, dynamic> cart;
  final String total;

  CartLoaded({required this.cart, required this.total});
}

class CartUpdated extends CartState {
  final String message;

  CartUpdated({required this.message});
}

class CartCanceled extends CartState {
  final String message;

  CartCanceled({required this.message});
}

class CartError extends CartState {
  final String message;

  CartError({required this.message});
}

class OrderCreated extends CartState {
  final String message;

  OrderCreated({required this.message});
}

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(CartInitial());

  final String baseUrl = 'http://10.0.2.2:8000/api';

  Future<String> _getAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ?? '';
  }

  Future<void> fetchCart() async {
    emit(CartLoading());
    try {
      String token = await _getAuthToken();

      if (token.isEmpty) {
        emit(CartError(message: 'No authentication token found'));
        return;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/cart'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final total = data['total'].toString();
        emit(CartLoaded(
            cart: data['cart'],
            total: total));
      } else {
        emit(CartError(message: 'Failed to fetch cart'));
      }
    } catch (e) {
      emit(CartError(message: e.toString()));
    }
  }

  Future<void> addToCart(int productId, int quantity) async {
    emit(CartLoading());
    try {
      String token = await _getAuthToken();

      final response = await http.post(
        Uri.parse('$baseUrl/cart/add'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'product_id': productId, 'quantity': quantity}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        emit(CartUpdated(message: data['message']));
        fetchCart();
      } else {
        emit(CartError(message: 'Failed to add item to cart'));
      }
    } catch (e) {
      emit(CartError(message: e.toString()));
    }
  }

  Future<void> editCartItem(int cartItemId, int quantity) async {
    emit(CartLoading());
    try {
      String token = await _getAuthToken();

      final response = await http.put(
        Uri.parse('$baseUrl/cart/edit'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'cart_item_id': cartItemId, 'quantity': quantity}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        emit(CartUpdated(message: data['message']));
        fetchCart();
      } else {
        emit(CartError(message: 'Failed to edit cart item'));
      }
    } catch (e) {
      emit(CartError(message: e.toString()));
    }
  }

  Future<void> deleteCartItem(int cartItemId) async {
    emit(CartLoading());
    try {
      String token = await _getAuthToken();

      final response = await http.delete(
        Uri.parse('$baseUrl/cart/item/delete'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'cart_item_id': cartItemId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        emit(CartUpdated(message: data['message']));
        fetchCart();
      } else {
        emit(CartError(message: 'Failed to delete cart item'));
      }
    } catch (e) {
      emit(CartError(message: e.toString()));
    }
  }

  Future<void> cancelCart() async {
    emit(CartLoading());
    try {
      String token = await _getAuthToken();

      final response = await http.delete(
        Uri.parse('$baseUrl/cart/cancel'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        emit(CartCanceled(message: data['message']));
        fetchCart();
      } else {
        emit(CartError(message: 'Failed to cancel cart'));
      }
    } catch (e) {
      emit(CartError(message: e.toString()));
    }
  }


  Future<void> createOrder(String paymentMethod, String? transactionId) async {
    try {
      emit(CartLoading());

      String token = await _getAuthToken();

      final response = await http.post(
        Uri.parse('$baseUrl/order/create'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'payment_method': paymentMethod,
          'transaction_id': transactionId,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        emit(OrderCreated(message: data['message']));
        await fetchCart(); // Refresh the cart after order creation
      } else {
        emit(CartError(message: 'Failed to create order'));
      }
    } catch (e) {
      emit(CartError(message: e.toString()));
    }
  }
}