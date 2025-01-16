import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/AddToCartCubit.dart';
import '../cubit/ProductDetailsCubit.dart';
import '../cubit/FavoritesCubit.dart';
import '../stores/StoreDetailsScreen.dart';

class ProductDetailsScreen extends StatelessWidget {
  final String productId;

  ProductDetailsScreen({required this.productId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProductDetailsCubit()..fetchProductDetails(productId),
      child: BlocBuilder<ProductDetailsCubit, ProductDetailsState>(
        builder: (context, state) {
          if (state.isLoading) {
            return Scaffold(
              appBar: AppBar(title: Text('Product Details')),
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (!state.isSuccess || state.productDetails == null) {
            return Scaffold(
              appBar: AppBar(title: Text('Product Details')),
              body: Center(child: Text(state.message)),
            );
          }

          final product = state.productDetails!;
          final store = product['store']; // Store details are inside the product object

          return Scaffold(
            appBar: AppBar(title: Text(product['name'] ?? 'Product Details')),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Image
                    Center(
                      child: Image.network(
                        product['image'] ?? 'https://via.placeholder.com/300',
                        height: 300,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: 16),

                    // Product Name
                    Text(
                      product['name'] ?? 'Unknown Product',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),

                    // Product Price
                    Text(
                      '\$${product['price']}',
                      style: TextStyle(fontSize: 20, color: Colors.green),
                    ),
                    SizedBox(height: 16),

                    // Product Description
                    Text(
                      product['description'] ?? 'No description available',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 16),

                    // Store Details Section
                    if (store != null) ...[
                      Text(
                        'Store Details:',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Store Name: ${store['name'] ?? 'Unknown Store'}',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Location: ${store['location'] ?? 'No location available'}',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Store Description: ${store['description'] ?? 'No description available'}',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 16),

                      // Button or Gesture to Navigate to Store Details
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StoreDetailsScreen(storeId: store['id'].toString()),
                            ),
                          );
                        },
                        child: Text('View Store Details'),
                      ),
                    ],

                    // Add to Cart Button
                    SizedBox(height: 16),
                    BlocProvider(
                      create: (context) => AddToCartCubit(),
                      child: BlocConsumer<AddToCartCubit, AddToCartState>(
                        listener: (context, addToCartState) {
                          if (addToCartState.isSuccess) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(addToCartState.message)),
                            );
                          } else if (addToCartState.message.isNotEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(addToCartState.message)),
                            );
                          }
                        },
                        builder: (context, addToCartState) {
                          return ElevatedButton(
                            onPressed: () {
                              context.read<AddToCartCubit>().addToCart(product['id'].toString(), 1);
                            },
                            child: addToCartState.isLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text('Add to Cart'),
                          );
                        },
                      ),
                    ),

                    // Add to Favorites Button
                    SizedBox(height: 16),
                    BlocProvider(
                      create: (context) => FavoritesCubit(),
                      child: BlocConsumer<FavoritesCubit, FavoritesState>(
                        listener: (context, favoritesState) {
                          if (favoritesState is FavoritesSuccess) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(favoritesState.message)),
                            );
                          } else if (favoritesState is FavoritesError) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(favoritesState.message)),
                            );
                          }
                        },
                        builder: (context, favoritesState) {
                          return IconButton(
                            icon: Icon(
                              favoritesState is FavoritesSuccess && favoritesState.isFavorited
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: favoritesState is FavoritesSuccess && favoritesState.isFavorited
                                  ? Colors.red
                                  : null,
                            ),
                            onPressed: () {
                              if (favoritesState is FavoritesSuccess && favoritesState.isFavorited) {
                                context.read<FavoritesCubit>().removeFromFavorites(product['id'].toString());
                              } else {
                                context.read<FavoritesCubit>().addToFavorites(product['id'].toString());
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
