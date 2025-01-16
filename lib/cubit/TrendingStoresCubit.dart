import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TrendingStoresState {
  final bool isLoading;
  final bool isSuccess;
  final String message;
  final List<dynamic>? stores;

  TrendingStoresState({
    this.isLoading = false,
    this.isSuccess = false,
    this.message = '',
    this.stores,
  });
}

class TrendingStoresCubit extends Cubit<TrendingStoresState> {
  TrendingStoresCubit() : super(TrendingStoresState());

  // Fetch trending stores from the API
  Future<void> fetchTrendingStores() async {
    emit(TrendingStoresState(isLoading: true));

    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/stores/trending'), // Replace with your API URL
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      emit(TrendingStoresState(
        isSuccess: true,
        stores: data['data'], // Assuming API returns stores in 'data' field
        message: 'Trending stores loaded successfully',
      ));
    } else {
      emit(TrendingStoresState(message: 'Failed to load trending stores'));
    }
  }
}