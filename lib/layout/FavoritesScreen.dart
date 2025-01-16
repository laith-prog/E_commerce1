import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
                  return ListTile(
                    title: Text(favorite['name'] ?? 'Unknown Product'),
                    subtitle: Text(favorite['description'] ?? 'No description available'),
                    leading: Icon(Icons.favorite, color: Colors.red),
                    onTap: () {
                      // Handle tap event (optional)
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
