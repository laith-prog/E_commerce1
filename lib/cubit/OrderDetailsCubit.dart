import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

class OrderDetailsState {
  final bool isLoading;
  final Map<String, dynamic>? order;
  final String? error;

  OrderDetailsState({this.isLoading = false, this.order, this.error});

  OrderDetailsState copyWith({bool? isLoading, Map<String, dynamic>? order, String? error}) {
    return OrderDetailsState(
      isLoading: isLoading ?? this.isLoading,
      order: order ?? this.order,
      error: error ?? this.error,
    );
  }
}

class OrderDetailsCubit extends Cubit<OrderDetailsState> {
  OrderDetailsCubit() : super(OrderDetailsState());

  final String baseUrl = "http://192.168.45.88:8000/api";


  Future<void> fetchOrderDetails(String token, int orderId) async {
    emit(state.copyWith(isLoading: true));
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/orders/$orderId"),
        headers: {'Authorization': 'Bearer $token'},
      );


      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        emit(state.copyWith(isLoading: false, order: data['order']));
      } else {
        emit(state.copyWith(isLoading: false, error: "Failed to fetch order details"));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> cancelOrder(String token, int orderId) async {
    try {
      emit(state.copyWith(isLoading: true));
      final response = await http.post(
        Uri.parse("$baseUrl/orders/$orderId/cancel"),
        headers: {'Authorization': 'Bearer $token'},
      );
      print(response.statusCode);
      print(response.body);
      print(token);
      if (response.statusCode == 200) {
        emit(state.copyWith(isLoading: false));
      fetchOrderDetails(token, orderId);
      } else {
        emit(state.copyWith(isLoading: false, error: "Failed to cancel order"));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> editOrder(String token, int orderId, List<Map<String, dynamic>> orderItems) async {
    try {
      emit(state.copyWith(isLoading: true));
      final response = await http.put(
        Uri.parse("$baseUrl/orders/$orderId"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'order_items': orderItems}),
      );
      print(response.statusCode);
      print(response.body);
      print(token);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        emit(state.copyWith(isLoading: false, order: data['order']));
      fetchOrderDetails(token, orderId);
      } else {
        emit(state.copyWith(isLoading: false, error: "Failed to edit order"));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
