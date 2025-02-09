import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../Product/ProductScreen.dart';
import '../cubit/TrendingProductCubit.dart';
import '../cubit/TrendingStoresCubit.dart';
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
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF47C7C)), // Warm Pink
                  ),
                );
              }

              return Scaffold(
                backgroundColor: Color(0xFFFFF9F4), // Soft Beige background
                body: NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      SliverAppBar(
                        toolbarHeight: 1,
                        backgroundColor: Color(0xFF2C2C2C), // Dark Brown
                        expandedHeight: 600,
                        floating: false,
                        pinned: true,
                        flexibleSpace: FlexibleSpaceBar(
                          background: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset('assets/bag.jpg', fit: BoxFit.cover),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.black.withOpacity(0.6),
                                      Colors.transparent,
                                    ],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 80,
                                left: 20,
                                right: 20,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Fulfill your \nNeeds',
                                      style: TextStyle(
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontFamily: 'Roboto', // Replace with your custom font
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
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4F4F4F), // Charcoal Gray
                                fontFamily: 'Roboto', // Replace with your custom font
                              ),
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
                                  child: SizedBox(
                                    width: 200, // Fixed width for each item
                                    child: Card(
                                      margin: EdgeInsets.only(
                                        left: 16.0,
                                        right: index == productsState.bestSellingProducts!.length - 1 ? 16.0 : 0,
                                        bottom: 8.0,
                                        top: 8.0,
                                      ),
                                      elevation: 12,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          gradient: LinearGradient(
                                            colors: [Color(0xFFFAFAFA), Color(0xFFFFF9F4)], // Off White to Soft Beige
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(15),
                                              child: Image.network(
                                                'http://192.168.45.88:8000/storage/' + product['image'],
                                                fit: BoxFit.cover,
                                                width: 180, // Constrain image width
                                                height: 130, // Constrain image height
                                                errorBuilder: (context, error, stackTrace) {
                                                  return Container(
                                                    width: 180,
                                                    height: 130,
                                                    color: Colors.grey[300],
                                                    child: Icon(Icons.error, color: Colors.red),
                                                  );
                                                },
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                              child: Text(
                                                product['name'] ?? 'Unknown Product',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF4F4F4F), // Charcoal Gray
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                              child: Text(
                                                '\$${product['price']}',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Color(0xFFF2C94C), // Muted Gold
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
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
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4F4F4F), // Charcoal Gray
                                fontFamily: 'Roboto', // Replace with your custom font
                              ),
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
                                          storeId: store['id'].toString(),
                                        ),
                                      ),
                                    );
                                  },
                                  child: SizedBox(
                                    width: 200, // Fixed width for each item
                                    child: Card(
                                      margin: EdgeInsets.only(
                                        left: 16.0,
                                        right: index == storeState.stores!.length - 1 ? 16.0 : 0,
                                        bottom: 8.0,
                                        top: 8.0,
                                      ),
                                      elevation: 12,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          gradient: LinearGradient(
                                            colors: [Color(0xFFFAFAFA), Color(0xFFFFF9F4)], // Off White to Soft Beige
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(15),
                                              child: Image.network(
                                                'http://192.168.45.88:8000/storage/' + store['image'],
                                                fit: BoxFit.cover,
                                                width: 180, // Constrain image width
                                                height: 130, // Constrain image height
                                                errorBuilder: (context, error, stackTrace) {
                                                  return Container(
                                                    width: 180,
                                                    height: 130,
                                                    color: Colors.grey[300],
                                                    child: Icon(Icons.error, color: Colors.red),
                                                  );
                                                },
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                              child: Text(
                                                store['name'] ?? 'Unknown Store',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF4F4F4F), // Charcoal Gray
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                        // Trending Products Section
                        if (productsState.trendingProducts != null && productsState.trendingProducts!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                            child: Text(
                              'Trending Products',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4F4F4F), // Charcoal Gray
                                fontFamily: 'Roboto', // Replace with your custom font
                              ),
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
                                          productId: product['id'].toString(),
                                        ),
                                      ),
                                    );
                                  },
                                  child: SizedBox(
                                    width: 210, // Reduced width to account for margins and padding
                                    child: Card(
                                      margin: EdgeInsets.only(
                                        left: 16.0,
                                        right: index == productsState.trendingProducts!.length - 1 ? 16.0 : 0,
                                        bottom: 8.0,
                                        top: 8.0,
                                      ),
                                      elevation: 12,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          gradient: LinearGradient(
                                            colors: [Color(0xFFFAFAFA), Color(0xFFFFF9F4)], // Off White to Soft Beige
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(15),
                                              child: Image.network(
                                                'http://192.168.45.88:8000/storage/' + product['image'],
                                                fit: BoxFit.cover,
                                                width: 190, // Constrain image width
                                                height: 140, // Constrain image height
                                                errorBuilder: (context, error, stackTrace) {
                                                  return Container(
                                                    width: 190,
                                                    height: 140,
                                                    color: Colors.grey[300],
                                                    child: Icon(Icons.error, color: Colors.red),
                                                  );
                                                },
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                              child: Text(
                                                product['name'] ?? 'Unknown Product',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF4F4F4F), // Charcoal Gray
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                              child: Text(
                                                '\$${product['price']}',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Color(0xFFF2C94C), // Muted Gold
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
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