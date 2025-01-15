import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductSearchState {
  final bool isLoading;
  final List<dynamic> products;
  final String error;

  ProductSearchState({
    this.isLoading = false,
    this.products = const [],
    this.error = '',
  });
}
class ProductSearchCubit extends Cubit<ProductSearchState> {
  ProductSearchCubit() : super(ProductSearchState());

  void searchProducts(String query) async {
    emit(ProductSearchState(isLoading: true));

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/products/search?query=$query'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        emit(ProductSearchState(
          isLoading: false,
          products: data['data'],
        ));
      } else {
        emit(ProductSearchState(
            isLoading: false, error: 'Failed to load products'));
      }
    } catch (e) {
      emit(ProductSearchState(isLoading: false, error: 'Error: $e'));
    }
  }
}
