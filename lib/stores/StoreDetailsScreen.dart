import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../Product/ProductScreen.dart';
import '../cubit/StoreCubit.dart';

class StoreDetailsScreen extends StatelessWidget {
  final String storeId;

  StoreDetailsScreen({required this.storeId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StoreCubit()..fetchStoreDetails(storeId),
      child: Scaffold(
        backgroundColor: Color(0xFFFFF9F4), // Soft Beige background
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
          title: BlocBuilder<StoreCubit, StoreState>(
            builder: (context, state) {
              return Text(
                state.isLoading ? 'Loading...' : (state.store?['name'] ?? 'Store Details'),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Roboto', // Replace with your custom font
                ),
              );
            },
          ),
        ),
        body: BlocBuilder<StoreCubit, StoreState>(
          builder: (context, state) {
            if (state.isLoading && state.products.isEmpty) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF47C7C)), // Warm Pink
                ),
              );
            }

            if (!state.isSuccess || state.store == null) {
              return Center(
                child: Text(
                  state.message.isEmpty ? 'Failed to load store details' : state.message,
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF4F4F4F), // Charcoal Gray
                  ),
                ),
              );
            }

            var store = state.store!;
            var storeName = store['name'] ?? 'Unknown Store';
            var storeDescription = store['description'] ?? 'No description available';
            var products = state.products;

            return NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                if (scrollNotification is ScrollEndNotification &&
                    scrollNotification.metrics.pixels == scrollNotification.metrics.maxScrollExtent) {
                  // Trigger fetch more products when scrolled to the bottom
                  context.read<StoreCubit>().fetchStoreDetails(storeId, isLoadMore: true);
                }
                return false;
              },
              child: ListView(
                padding: EdgeInsets.all(16.0),
                children: [
                  // Store Logo with background and rounded corners
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                            ('http://192.168.45.88:8000/storage/' + store['image'])),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 10,
                          color: Colors.black26,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Container(
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
                  ),
                  SizedBox(height: 20),
                  // Store Name and Description with better font styling
                  Text(
                    storeName,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4F4F4F), // Charcoal Gray
                      fontFamily: 'Roboto', // Replace with your custom font
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    storeDescription,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF4F4F4F).withOpacity(0.7), // Charcoal Gray with opacity
                      fontFamily: 'Roboto', // Replace with your custom font
                    ),
                  ),
                  SizedBox(height: 24),
                  // Show Products if available
                  if (products.isNotEmpty) ...[
                    Text(
                      'Products Available:',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4F4F4F), // Charcoal Gray
                        fontFamily: 'Roboto', // Replace with your custom font
                      ),
                    ),
                    SizedBox(height: 16),
                    // Display products in a GridView for a more visually appealing layout
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // 2 products per row
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                        childAspectRatio: 0.7, // Adjust card aspect ratio
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        var product = products[index];
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
                            elevation: 8, // Softer shadow for the product card
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            color: Colors.white, // White background for card
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Product Image with rounded corners
                                ClipRRect(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16),
                                  ),
                                  child: Image.network(
                                    ('http://192.168.45.88:8000/storage/' + product['image']) ?? 'https://via.placeholder.com/150',
                                    height: 140, // Reduced height to prevent overflow
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        height: 140,
                                        width: double.infinity,
                                        color: Colors.grey[300],
                                        child: Icon(Icons.error, color: Colors.red),
                                      );
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Product Name
                                      Text(
                                        product['name'] ?? 'Unknown Product',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Color(0xFF4F4F4F), // Charcoal Gray
                                          fontFamily: 'Roboto', // Replace with your custom font
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 8),
                                      // Product Price
                                      Text(
                                        '\$${product['price'] ?? '0.00'}',
                                        style: TextStyle(
                                          color: Color(0xFFF2C94C), // Muted Gold for price
                                          fontSize: 14,
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
                        );
                      },
                    ),
                    // Show a loading spinner when loading more products
                    if (state.isLoading)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF47C7C)), // Warm Pink
                          ),
                        ),
                      ),
                  ] else
                    Text(
                      'No products available for this store.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF4F4F4F).withOpacity(0.7), // Charcoal Gray with opacity
                        fontFamily: 'Roboto', // Replace with your custom font
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}