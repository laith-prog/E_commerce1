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
              appBar: AppBar(
                title: Text(
                  'Product Details',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Roboto', // Replace with your custom font
                  ),
                ),
                backgroundColor: Colors.transparent,
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFF47C7C), Color(0xFFD64A4A)], // Warm Pink to Deep Pink
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
              body: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF47C7C)), // Warm Pink
                ),
              ),
            );
          }

          if (!state.isSuccess || state.productDetails == null) {
            return Scaffold(
              appBar: AppBar(
                title: Text(
                  'Product Details',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Roboto', // Replace with your custom font
                  ),
                ),
                backgroundColor: Colors.transparent,
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFF47C7C), Color(0xFFD64A4A)], // Warm Pink to Deep Pink
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
              body: Center(
                child: Text(
                  state.message,
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF4F4F4F), // Charcoal Gray
                    fontFamily: 'Roboto', // Replace with your custom font
                  ),
                ),
              ),
            );
          }

          final product = state.productDetails!;
          final store = product['store'];

          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFF47C7C), Color(0xFFD64A4A)], // Warm Pink to Deep Pink
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              title: Text(
                product['name'] ?? 'Product Details',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Roboto', // Replace with your custom font
                ),
              ),
            ),
            backgroundColor: Color(0xFFFFF9F4), // Soft Beige
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Image with shadow
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: double.infinity, // Ensure the container takes full width
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                offset: Offset(0, 4),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Image.network(
                                ('http://192.168.45.88:8000/storage/' + product['image']) ?? 'https://via.placeholder.com/300',
                                width: double.infinity, // Ensure the image takes full width
                                height: 300, // Fixed height for the image
                                fit: BoxFit.cover, // Ensure the image covers the container
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.black.withOpacity(0.4),
                                      Colors.transparent,
                                    ],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Product Name
                    Text(
                      product['name'] ?? 'Unknown Product',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4F4F4F), // Charcoal Gray
                        fontFamily: 'Roboto', // Replace with your custom font
                      ),
                    ),
                    SizedBox(height: 8),

                    // Product Price
                    Text(
                      '\$${product['price']}',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF2C94C), // Muted Gold
                        fontFamily: 'Roboto', // Replace with your custom font
                      ),
                    ),
                    SizedBox(height: 16),

                    // Product Description in a Card
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: Color(0xFFFAFAFA), // Off White for the card
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          product['description'] ?? 'No description available',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF4F4F4F).withOpacity(0.7), // Charcoal Gray with opacity
                            fontFamily: 'Roboto', // Replace with your custom font
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24),

                    // Store Details Section
                    if (store != null) ...[
                      Text(
                        'Store Details:',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4F4F4F), // Charcoal Gray
                          fontFamily: 'Roboto', // Replace with your custom font
                        ),
                      ),
                      SizedBox(height: 8),
                      _buildStoreDetails(store),
                      SizedBox(height: 24),
                      // Button to navigate to store details
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFF47C7C), // Warm Pink
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StoreDetailsScreen(storeId: store['id'].toString()),
                            ),
                          );
                        },
                        child: Text(
                          'View Store Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Roboto', // Replace with your custom font
                          ),
                        ),
                      ),
                    ],

                    // Add to Cart Button with Gradient
                    SizedBox(height: 24),
                    _buildAddToCartButton(product['id'].toString()),

                    // Add to Favorites Button
                    SizedBox(height: 16),
                    _buildFavoritesButton(product['id'].toString()),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStoreDetails(Map store) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Store Name: ${store['name'] ?? 'Unknown Store'}',
          style: TextStyle(
            fontSize: 18,
            color: Color(0xFF4F4F4F).withOpacity(0.7), // Charcoal Gray with opacity
            fontFamily: 'Roboto', // Replace with your custom font
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Location: ${store['location'] ?? 'No location available'}',
          style: TextStyle(
            fontSize: 18,
            color: Color(0xFF4F4F4F).withOpacity(0.7), // Charcoal Gray with opacity
            fontFamily: 'Roboto', // Replace with your custom font
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Store Description: ${store['description'] ?? 'No description available'}',
          style: TextStyle(
            fontSize: 18,
            color: Color(0xFF4F4F4F).withOpacity(0.7), // Charcoal Gray with opacity
            fontFamily: 'Roboto', // Replace with your custom font
          ),
        ),
      ],
    );
  }

  Widget _buildAddToCartButton(String productId) {
    return BlocProvider(
      create: (context) => AddToCartCubit(),
      child: BlocConsumer<AddToCartCubit, AddToCartState>(
        listener: (context, addToCartState) {
          if (addToCartState.isSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(addToCartState.message),
                backgroundColor: Color(0xFFF2C94C), // Muted Gold
              ),
            );
          } else if (addToCartState.message.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(addToCartState.message),
                backgroundColor: Color(0xFFD64A4A), // Deep Pink
              ),
            );
          }
        },
        builder: (context, addToCartState) {
          return ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFF2C94C), // Muted Gold
              padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () {
              context.read<AddToCartCubit>().addToCart(productId, 1);
            },
            child: addToCartState.isLoading
                ? CircularProgressIndicator(color: Colors.white)
                : Text(
              'Add to Cart',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Roboto', // Replace with your custom font
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFavoritesButton(String productId) {
    return BlocProvider(
      create: (context) => FavoritesCubit(),
      child: BlocConsumer<FavoritesCubit, FavoritesState>(
        listener: (context, favoritesState) {
          if (favoritesState is FavoritesSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(favoritesState.message),
                backgroundColor: Color(0xFFF2C94C), // Muted Gold
              ),
            );
          } else if (favoritesState is FavoritesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(favoritesState.message),
                backgroundColor: Color(0xFFD64A4A), // Deep Pink
              ),
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
                  ? Color(0xFFD64A4A) // Deep Pink for favorite
                  : Color(0xFF4F4F4F), // Charcoal Gray for non-favorite
            ),
            onPressed: () {
              if (favoritesState is FavoritesSuccess && favoritesState.isFavorited) {
                context.read<FavoritesCubit>().removeFromFavorites(productId);
              } else {
                context.read<FavoritesCubit>().addToFavorites(productId);
              }
            },
          );
        },
      ),
    );
  }
}