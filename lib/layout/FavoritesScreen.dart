import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../Product/ProductScreen.dart';
import '../cubit/FavoritesCubit.dart';

class FavoritesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FavoritesCubit()..fetchFavorites(),
      child: Scaffold(
        appBar: AppBar(title: Text('Favorites')),
        body: BlocBuilder<FavoritesCubit, FavoritesState>(
          builder: (context, state) {
            if (state is FavoritesLoading) {
              return Center(child: CircularProgressIndicator());
            }

            if (state is FavoritesError) {
              return Center(child: Text(state.message));
            }

            if (state is FavoritesLoaded) {
              if (state.favorites.isEmpty) {
                return Center(child: Text('No favorites found.'));
              }

              return ListView.builder(
                itemCount: state.favorites.length,
                itemBuilder: (context, index) {
                  final favorite = state.favorites[index];
                  final product = favorite['product'];  // Accessing the 'product' field

                  return ListTile(
                    title: Text(product['name'] ?? 'No name available'),
                    subtitle: Text(product['description'] ?? 'No description available'),
                    leading: IconButton(
                      icon: Icon(
                        Icons.favorite,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        // Remove from favorites and trigger UI update
                        context.read<FavoritesCubit>().removeFromFavorites(product['id'].toString());
                      },
                    ),
                    onTap: () {
                      // Navigate to ProductDetailScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailsScreen(
                            productId: product['id'].toString(),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            }

            return Center(child: Text('No data available.'));
          },
        ),
      ),
    );
  }
}
