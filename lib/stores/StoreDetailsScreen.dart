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
        backgroundColor: Color(0xFFF5F5F5),  // Lighter background color
        appBar: AppBar(
          backgroundColor: Color(0xFFEB8F8F),  // Softer pink for the app bar
          title: BlocBuilder<StoreCubit, StoreState>(
            builder: (context, state) {
              return Text(
                state.isLoading ? 'Loading...' : (state.store?['name'] ?? 'Store Details'),
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              );
            },
          ),
        ),
        body: BlocBuilder<StoreCubit, StoreState>(
          builder: (context, state) {
            if (state.isLoading && state.products.isEmpty) {
              return Center(child: CircularProgressIndicator());
            }

            if (!state.isSuccess || state.store == null) {
              return Center(
                child: Text(
                  state.message.isEmpty ? 'Failed to load store details' : state.message,
                  style: TextStyle(fontSize: 18, color: Colors.grey),
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
                        image: NetworkImage(store['logo'] ?? 'https://via.placeholder.com/150'),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26, offset: Offset(0, 4))],
                    ),
                  ),
                  SizedBox(height: 20),
                  // Store Name and Description with better font styling
                  Text(
                    storeName,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3A3A3A),  // Darker text for better contrast
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    storeDescription,
                    style: TextStyle(fontSize: 16, color: Color(0xFF636363)),
                  ),
                  SizedBox(height: 24),
                  // Show Products if available
                  if (products.isNotEmpty) ...[
                    Text(
                      'Products Available:',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3A3A3A),
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
                            elevation: 8,  // Softer shadow for the product card
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            color: Color(0xFFFFFFFF),  // White background for card
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Product Image with rounded corners
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.network(
                                    product['image'] ?? 'https://via.placeholder.com/150',
                                    height: 180,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
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
                                          color: Color(0xFF4A4A4A),
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 8),
                                      // Product Price
                                      Text(
                                        '\$${product['price'] ?? '0.00'}',
                                        style: TextStyle(
                                          color: Color(0xFFF29C11),  // Soft Gold for price
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
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
                        child: Center(child: CircularProgressIndicator()),
                      ),
                  ] else
                    Text(
                      'No products available for this store.',
                      style: TextStyle(fontSize: 16, color: Color(0xFF636363)),
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
