import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TrendingStoresState {
  final bool isLoading;
  final bool isSuccess;
  final String message;
  final List<dynamic>? stores;
  final List<dynamic>? allStores; // Added this line

  TrendingStoresState({
    this.isLoading = false,
    this.isSuccess = false,
    this.message = '',
    this.stores,
    this.allStores, // Added this line
  });
  TrendingStoresState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? message,
    List<dynamic>? stores,
    List<dynamic>? allStores,
  }) {
    return TrendingStoresState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      message: message ?? this.message,
      stores: stores ?? this.stores,
      allStores: allStores ?? this.allStores,
    );
  }
}

class TrendingStoresCubit extends Cubit<TrendingStoresState> {
  TrendingStoresCubit() : super(TrendingStoresState());

  Future<void> fetchAllStores() async {
    emit(state.copyWith(isLoading: true));

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/stores'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        emit(state.copyWith(
          isSuccess: true,
          allStores: data['data'],
          message: 'All stores loaded successfully',
        ));
      } else {
        emit(state.copyWith(message: 'Failed to load all stores'));
      }
    } catch (e) {
      emit(state.copyWith(message: 'Error: $e'));
    }
  }



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