import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StoreSearchState {
  final bool isLoading;
  final List<dynamic> stores;
  final String error;

  StoreSearchState({
    this.isLoading = false,
    this.stores = const [],
    this.error = '',
  });
}

class StoreSearchCubit extends Cubit<StoreSearchState> {
  StoreSearchCubit() : super(StoreSearchState());

  // Pagination state
  int _page = 1; // The page number
  final int _pageSize = 10; // Number of items per page

  void searchStores(String query, {bool isLoadMore = false}) async {
    // Reset page for fresh search
    if (!isLoadMore) {
      _page = 1;
    }

    // Show loading state and keep previous stores if loading more
    emit(StoreSearchState(isLoading: true, stores: isLoadMore ? state.stores : [], error: state.error));

    try {
      final response = await http.get(
        Uri.parse(
            'http://10.0.2.2:8000/api/stores/search?query=$query&page=$_page&per_page=$_pageSize'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> fetchedStores = data['data'];

        if (isLoadMore) {
          // Append new stores if it's a load more request
          emit(StoreSearchState(
            isLoading: false,
            stores: List.from(state.stores)..addAll(fetchedStores),
          ));
        } else {
          // Replace stores if it's a fresh search
          emit(StoreSearchState(
            isLoading: false,
            stores: fetchedStores,
          ));
        }

        // Increment the page for the next request if there are more stores
        if (fetchedStores.length == _pageSize) {
          _page++; // Increase the page number
        }
      } else {
        emit(StoreSearchState(isLoading: false, error: 'Failed to load stores'));
      }
    } catch (e) {
      emit(StoreSearchState(isLoading: false, error: 'Error: $e'));
    }
  }
}
