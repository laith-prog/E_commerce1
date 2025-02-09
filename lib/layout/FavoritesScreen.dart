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
        backgroundColor: Color(0xFFFFF9F4), // Soft Beige background
        body: BlocBuilder<FavoritesCubit, FavoritesState>(
          builder: (context, state) {
            if (state is FavoritesLoading) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF47C7C)), // Warm Pink
                ),
              );
            }

            if (state is FavoritesError) {
              return Center(
                child: Text(
                  state.message,
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF4F4F4F), // Charcoal Gray
                    fontFamily: 'Roboto', // Replace with your custom font
                  ),
                ),
              );
            }

            if (state is FavoritesLoaded) {
              if (state.favorites.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 60,
                        color: Color(0xFF4F4F4F), // Charcoal Gray
                      ),
                      SizedBox(height: 20),
                      Text(
                        'No favorites found.',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF4F4F4F), // Charcoal Gray
                          fontFamily: 'Roboto', // Replace with your custom font
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.all(12),
                itemCount: state.favorites.length,
                itemBuilder: (context, index) {
                  final favorite = state.favorites[index];
                  final product = favorite['product']; // Accessing the 'product' field

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16), // Rounded corners for card
                    ),
                    elevation: 6, // Increased elevation for depth
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [Color(0xFFFAFAFA), Color(0xFFFFF9F4)], // Off White to Soft Beige
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            'http://192.168.45.88:8000/storage/' +product['image'] ?? 'https://via.placeholder.com/150',
                            width: 80, // Image size increased for prominence
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(
                          product['name'] ?? 'No name available',
                          style: TextStyle(
                            fontSize: 18, // Increased font size for better readability
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4F4F4F), // Charcoal Gray color
                            fontFamily: 'Roboto', // Replace with your custom font
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          product['description'] ?? 'No description available',
                          style: TextStyle(
                            fontSize: 14, // Slightly larger subtitle
                            color: Color(0xFF4F4F4F).withOpacity(0.7), // Charcoal Gray with opacity
                            fontFamily: 'Roboto', // Replace with your custom font
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.favorite, color: Color(0xFFD64A4A), size: 30), // Deep Pink
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
                      ),
                    ),
                  );
                },
              );
            }

            return Center(
              child: Text(
                'No data available.',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF4F4F4F), // Charcoal Gray
                  fontFamily: 'Roboto', // Replace with your custom font
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}