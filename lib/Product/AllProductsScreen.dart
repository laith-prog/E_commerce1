import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/TrendingProductCubit.dart';
import 'ProductScreen.dart';

class AllProductsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'All Products',
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
      body: BlocProvider(
        create: (context) => ProductsCubit()..fetchAllProducts(),
        child: BlocConsumer<ProductsCubit, ProductsState>(
          listener: (context, state) {
            // Only show the snackbar for specific conditions
            if (state.message.isNotEmpty && state.message != 'Products loaded successfully') {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Color(0xFFD64A4A), // Deep Pink
                ),
              );
            }
          },
          builder: (context, state) {
            // Show loading spinner when data is loading
            if (state.isLoading && (state.allProducts == null || state.allProducts!.isEmpty)) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF47C7C)), // Warm Pink
                ),
              );
            }

            // Show message if no products are found
            if (state.allProducts == null || state.allProducts!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 60,
                      color: Color(0xFF4F4F4F), // Charcoal Gray
                    ),
                    SizedBox(height: 20),
                    Text(
                      'No products available',
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF4F4F4F), // Charcoal Gray
                        fontFamily: 'Roboto', // Replace with your custom font
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ProductsCubit>().fetchAllProducts();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFF47C7C), // Warm Pink
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Retry',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontFamily: 'Roboto', // Replace with your custom font
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            // Display products in a grid
            return NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                // Load more products when reaching the bottom of the list
                if (!state.isLoading &&
                    scrollNotification is ScrollEndNotification &&
                    scrollNotification.metrics.pixels == scrollNotification.metrics.maxScrollExtent &&
                    context.read<ProductsCubit>().hasMoreProducts) {
                  context.read<ProductsCubit>().fetchAllProducts(isPaginated: true);
                }
                return false;
              },
              child: GridView.builder(
                padding: EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: state.allProducts!.length,
                itemBuilder: (context, index) {
                  var product = state.allProducts![index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailsScreen(
                            productId: product['id'].toString(),
                          ),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: LinearGradient(
                            colors: [Color(0xFFFAFAFA), Color(0xFFFFF9F4)], // Off White to Soft Beige
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                              child: Image.network(
                                'http://192.168.45.88:8000/storage/' + product['image'],
                                height: 140,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    'assets/logo_transparent.png',
                                    height: 140,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['name'] ?? 'Unknown Product',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF4F4F4F), // Charcoal Gray
                                      fontFamily: 'Roboto', // Replace with your custom font
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '\$${product['price'] ?? 'N/A'}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFFF2C94C), // Muted Gold
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Roboto', // Replace with your custom font
                                    ),
                                  ),
                                ],
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
          },
        ),
      ),
    );
  }
}