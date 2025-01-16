import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../Product/ProductScreen.dart';
import '../cubit/ProductCubit.dart';
import '../cubit/StoreCubit.dart';
import '../cubit/TrendingStoreCubit.dart';
import '../stores/StoreDetailsScreen.dart';

class HomeContentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ProductsCubit()..fetchProducts()),
        BlocProvider(create: (context) => TrendingStoresCubit()..fetchTrendingStores()),
      ],
      child: BlocBuilder<ProductsCubit, ProductsState>(
        builder: (context, productsState) {
          return BlocBuilder<TrendingStoresCubit, TrendingStoresState>(
            builder: (context, storeState) {
              if (productsState.isLoading || storeState.isLoading) {
                return Center(child: CircularProgressIndicator());
              }

              return ListView(
                children: [
                  // Trending Products Section (Horizontal Scroll, Large Size)
                  if (productsState.trendingProducts != null &&
                      productsState.trendingProducts!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Trending Products',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                    ),
                  if (productsState.trendingProducts != null &&
                      productsState.trendingProducts!.isNotEmpty)
                    Container(
                      height: 250, // Adjust the height of the card container
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: productsState.trendingProducts!.length,
                        itemBuilder: (context, index) {
                          var product = productsState.trendingProducts![index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailsScreen(
                                    productId: product['id']
                                        .toString(), // Pass the product ID
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              margin: EdgeInsets.symmetric(horizontal: 8.0),
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Container(
                                width: 250,
                                child: Column(
                                  children: [
                                    Image.network(
                                      product['image'] ??
                                          'https://via.placeholder.com/150',
                                      height: 150,
                                      width: 250,
                                      fit: BoxFit.contain,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      product['name'] ?? 'Unknown Product',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      '\$${product['price']}',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.green),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  // Best Selling Products Section (Horizontal Scroll, Smaller Size)
                  if (productsState.bestSellingProducts != null &&
                      productsState.bestSellingProducts!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Best Selling Products',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                    ),
                  if (productsState.bestSellingProducts != null &&
                      productsState.bestSellingProducts!.isNotEmpty)
                    Container(
                      height: 200, // Adjust the height for smaller cards
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: productsState.bestSellingProducts!.length,
                        itemBuilder: (context, index) {
                          var product =
                              productsState.bestSellingProducts![index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailsScreen(
                                    productId: product['id']
                                        .toString(), // Pass the product ID
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              margin: EdgeInsets.symmetric(horizontal: 8.0),
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Container(
                                width: 200,
                                // Smaller size for best selling products
                                child: Column(
                                  children: [
                                    Image.network(
                                      product['image'] ??
                                          'https://via.placeholder.com/150',
                                      height: 130,
                                      width: 200,
                                      fit: BoxFit.cover,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      product['name'] ?? 'Unknown Product',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      '\$${product['price']}',
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.green),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  // Trending Stores Section (Horizontal Scroll, Medium Size)
                  if (storeState.stores != null &&
                      storeState.stores!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Trending Stores',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                    ),
                  if (storeState.stores != null &&
                      storeState.stores!.isNotEmpty)
                    Container(
                      height: 200,
                      // Adjust the height for medium-sized store cards
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: storeState.stores!.length,
                        itemBuilder: (context, index) {
                          var store = storeState.stores![index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StoreDetailsScreen(
                                      storeId: store['id'].toString()),
                                ),
                              );
                            },
                            child: Card(
                              margin: EdgeInsets.symmetric(horizontal: 8.0),
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Container(
                                width: 220, // Medium size for stores
                                child: Column(
                                  children: [
                                    Image.network(
                                      store['logo'] ??
                                          'https://via.placeholder.com/150',
                                      height: 120,
                                      width: 220,
                                      fit: BoxFit.cover,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      store['name'] ?? 'Unknown Store',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      store['description'] ?? 'No description',
                                      style: TextStyle(fontSize: 14),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
