
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
        title: Text('All Stores'),
        backgroundColor: Color(0xFF2C2C2C),
      ),
      body: BlocProvider(
        create: (context) => TrendingStoresCubit()..fetchAllStores(),
        child: BlocConsumer<TrendingStoresCubit, TrendingStoresState>(
          listener: (BuildContext context, TrendingStoresState state) {
            if (state.message.isNotEmpty && state.message != 'Products loaded successfully') {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            // Display a loading spinner when data is being fetched and no stores are loaded
            if (state.isLoading && state.allStores == null) {
              return Center(child: CircularProgressIndicator());
            }

            // Handle case when no stores are available
            if (state.allStores == null || state.allStores!.isEmpty) {
              return Center(child: Text('No stores available'));
            }

            // Scroll detection
            _scrollController.addListener(() {
              if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
                // Trigger fetch for more stores when bottom is reached
                context.read<TrendingStoresCubit>().fetchAllStores();
              }
            });

            return GridView.builder(
              controller: _scrollController,  // Attach ScrollController
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                          child: Image.asset(
                            'assets/logo_transparent.png',
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
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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
