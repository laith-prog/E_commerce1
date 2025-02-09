import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

abstract class FavoritesState {}

class FavoritesInitial extends FavoritesState {}

class FavoritesLoading extends FavoritesState {}

class FavoritesSuccess extends FavoritesState {
  final String message;
  final bool isFavorited;

  FavoritesSuccess({required this.message, required this.isFavorited});
}

class FavoritesLoaded extends FavoritesState {
  final List<dynamic> favorites;

  FavoritesLoaded({required this.favorites});
}
class FavoritesError extends FavoritesState {
  final String message;

  FavoritesError({required this.message});
}

class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit() : super(FavoritesInitial());

  final String baseUrl = 'http://192.168.45.88:8000/api'; // Replace with your API URL

  // Function to get auth token
  Future<String> _getAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ?? ''; // Return token or empty string if not found
  }

  // Add product to favorites
  Future<void> addToFavorites(String productId) async {
    emit(FavoritesLoading());
    try {
      String token = await _getAuthToken();

      if (token.isEmpty) {
        emit(FavoritesError(message: 'No authentication token found'));
        return;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/favorites/add'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'product_id': productId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        emit(FavoritesSuccess(message: data['message'], isFavorited: true));
      } else {
        emit(FavoritesError(message: 'Failed to add product to favorites'));
      }
    } catch (e) {
      emit(FavoritesError(message: e.toString()));
    }
  }

  // Remove product from favorites
  Future<void> removeFromFavorites(String productId) async {
    emit(FavoritesLoading());
    try {
      String token = await _getAuthToken();

      if (token.isEmpty) {
        emit(FavoritesError(message: 'No authentication token found'));
        return;
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/favorites/remove/$productId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        fetchFavorites();
        emit(FavoritesSuccess(message: data['message'], isFavorited: false));
      } else {
        emit(FavoritesError(message: 'Failed to remove product from favorites'));
      }
    } catch (e) {
      emit(FavoritesError(message: e.toString()));
    }
  }
  Future<void> fetchFavorites() async {
    emit(FavoritesLoading());
    try {
      String token = await _getAuthToken();

      if (token.isEmpty) {
        emit(FavoritesError(message: 'No authentication token found'));
        return;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/favorites'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        emit(FavoritesLoaded(favorites: data['favorites']));
      } else {
        print(response.body);
        emit(FavoritesError(message: 'Failed to fetch favorites'));
      }
    } catch (e) {
      emit(FavoritesError(message: e.toString()));
    }
  }
}