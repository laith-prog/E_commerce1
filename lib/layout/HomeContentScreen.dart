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

              return Scaffold(
                backgroundColor: Color(0xFFFFF9F4),
                body: NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      SliverAppBar(
                        toolbarHeight: 1,
                        backgroundColor: Color(0xFF2C2C2C),
                        expandedHeight: 600,
                        floating: false,
                        pinned: true,
                        flexibleSpace: FlexibleSpaceBar(
                          background: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset('assets/bag.jpg', fit: BoxFit.cover),
                              Positioned(
                                top: 80,
                                left: 0,
                                right: 20,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Fulfill your \nNeeds',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontSize: 70,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ];
                  },
                  body: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Best Selling Products Section
                        if (productsState.bestSellingProducts != null && productsState.bestSellingProducts!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                            child: Text(
                              'Best Selling Products',
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF4F4F4F)),
                            ),
                          ),
                        if (productsState.bestSellingProducts != null && productsState.bestSellingProducts!.isNotEmpty)
                          Container(
                            height: 250,
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: productsState.bestSellingProducts!.length,
                              itemBuilder: (context, index) {
                                var product = productsState.bestSellingProducts![index];
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
                                    margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                    elevation: 12,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Container(
                                      width: 210,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: Colors.white,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(15),
                                            child: Image.asset(
                                              'assets/logo_transparent.png',
                                              fit: BoxFit.cover,
                                              width: 210,
                                              height: 140,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                            child: Text(
                                              product['name'] ?? 'Unknown Product',
                                              style: TextStyle(
                                                  fontSize: 16, fontWeight: FontWeight.bold),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                            child: Text(
                                              '\$${product['price']}',
                                              style: TextStyle(fontSize: 14, color: Colors.green),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                        // Trending Stores Section
                        if (storeState.stores != null && storeState.stores!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                            child: Text(
                              'Trending Stores',
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF4F4F4F)),
                            ),
                          ),
                        if (storeState.stores != null && storeState.stores!.isNotEmpty)
                          Container(
                            height: 250,
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
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
                                    margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                    elevation: 12,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Container(
                                      width: 220,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: Colors.white,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(15),
                                            child: Image.asset(
                                              'assets/logo_transparent.png',
                                              fit: BoxFit.cover,
                                              width: 220,
                                              height: 130,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                            child: Text(
                                              store['name'] ?? 'Unknown Store',
                                              style: TextStyle(
                                                  fontSize: 16, fontWeight: FontWeight.bold),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                        // Trending Products Section (Make sure this is only rendered when there are products)
                        if (productsState.trendingProducts != null && productsState.trendingProducts!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                            child: Text(
                              'Trending Products',
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF4F4F4F)),
                            ),
                          ),
                        if (productsState.trendingProducts != null && productsState.trendingProducts!.isNotEmpty)
                          Container(
                            height: 270,
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
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
                                          productId: product['id'].toString(), // Pass the product ID
                                        ),
                                      ),
                                    );
                                  },
                                  child: Card(
                                    margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                    elevation: 12,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Container(
                                      width: 240,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: Colors.white,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(15),
                                            child: Image.asset(
                                              'assets/logo_transparent.png', // Local image
                                              fit: BoxFit.cover,
                                              width: 240,
                                              height: 160,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                            child: Text(
                                              product['name'] ?? 'Unknown Product',
                                              style: TextStyle(
                                                  fontSize: 18, fontWeight: FontWeight.bold),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                            child: Text(
                                              '\$${product['price']}',
                                              style: TextStyle(fontSize: 16, color: Colors.green),
                                            ),
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
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
