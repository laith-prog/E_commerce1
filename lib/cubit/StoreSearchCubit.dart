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

  void searchStores(String query) async {
    emit(StoreSearchState(isLoading: true));

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/stores/search?query=$query'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        emit(StoreSearchState(
          isLoading: false,
          stores: data['data'],
        ));
      } else {
        emit(StoreSearchState(isLoading: false, error: 'Failed to load stores'));
      }
    } catch (e) {
      emit(StoreSearchState(isLoading: false, error: 'Error: $e'));
    }
  }
}
