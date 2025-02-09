import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/TrendingStoresCubit.dart';
import 'StoreDetailsScreen.dart';

class AllStoresScreen extends StatelessWidget {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'All Stores',
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
        create: (context) => TrendingStoresCubit()..fetchAllStores(),
        child: BlocConsumer<TrendingStoresCubit, TrendingStoresState>(
          listener: (BuildContext context, TrendingStoresState state) {
            if (state.message.isNotEmpty && state.message != 'Stores loaded successfully') {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Color(0xFFD64A4A), // Deep Pink
                ),
              );
            }
          },
          builder: (context, state) {
            // Display a loading spinner when data is being fetched and no stores are loaded
            if (state.isLoading && state.allStores == null) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF47C7C)), // Warm Pink
                ),
              );
            }

            // Handle case when no stores are available
            if (state.allStores == null || state.allStores!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.store_outlined,
                      size: 60,
                      color: Color(0xFF4F4F4F), // Charcoal Gray
                    ),
                    SizedBox(height: 20),
                    Text(
                      'No stores available',
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF4F4F4F), // Charcoal Gray
                        fontFamily: 'Roboto', // Replace with your custom font
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<TrendingStoresCubit>().fetchAllStores();
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

            // Scroll detection
            _scrollController.addListener(() {
              if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
                // Trigger fetch for more stores when bottom is reached
                context.read<TrendingStoresCubit>().fetchAllStores();
              }
            });

            return GridView.builder(
              controller: _scrollController, // Attach ScrollController
              padding: EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: state.allStores!.length,
              itemBuilder: (context, index) {
                var store = state.allStores![index];
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
                              'http://192.168.45.88:8000/storage/' + store['image'],
                              height: 140,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              store['name'] ?? 'Unknown Store',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4F4F4F), // Charcoal Gray
                                fontFamily: 'Roboto', // Replace with your custom font
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
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
      ),
    );
  }
}