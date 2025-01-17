import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

class OrdersState {
  final bool isLoading;
  final List<dynamic>? orders;
  final String? error;

  OrdersState({this.isLoading = false, this.orders, this.error});

  OrdersState copyWith({bool? isLoading, List<dynamic>? orders, String? error}) {
    return OrdersState(
      isLoading: isLoading ?? this.isLoading,
      orders: orders ?? this.orders,
      error: error ?? this.error,
    );
  }
}

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit() : super(OrdersState());

  final String baseUrl = "http://10.0.2.2:8000/api";

  Future<void> fetchOrders(String token) async {
    emit(state.copyWith(isLoading: true));
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/orders"),
        headers: {'Authorization': 'Bearer $token'},
      );

      print(response.body);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        emit(state.copyWith(isLoading: false, orders: data['orders']));
      } else {
        emit(state.copyWith(isLoading: false, error: "Failed to fetch orders"));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
