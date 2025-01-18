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
  int currentPage = 1; // Track the current page
  bool hasMoreStores = true; // Track if there are more stores to load

  TrendingStoresCubit() : super(TrendingStoresState());

  // Method to fetch all stores with pagination
  Future<void> fetchAllStores() async {
    // Check if there are more stores to load
    if (!hasMoreStores) return;

    emit(state.copyWith(isLoading: true));

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/stores?page=$currentPage'),
      );
      print(response.body);
      print(response.statusCode);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> fetchedStores = data['data'];

        // If stores are available, update the state
        if (fetchedStores.isNotEmpty) {
          emit(state.copyWith(
            isLoading: false,
            isSuccess: true,
            allStores: [...?state.allStores, ...fetchedStores], // Append new stores
            message: 'All stores loaded successfully',
          ));
          currentPage++; // Increment the page for the next request
        } else {
          // If no stores are returned, stop pagination
          hasMoreStores = false;
          emit(state.copyWith(
            isLoading: false,
            message: 'No more stores available',
          ));
        }
      } else {
        emit(state.copyWith(
          isLoading: false,
          message: 'Failed to load all stores',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        message: 'Error: $e',
      ));
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