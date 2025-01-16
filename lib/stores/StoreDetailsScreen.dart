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
        appBar: AppBar(
          title: BlocBuilder<StoreCubit, StoreState>(
            builder: (context, state) {
              return Text(
                state.isLoading
                    ? 'Loading...'
                    : (state.store?['name'] ?? 'Store Details'),
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
                child: Text(state.message.isEmpty
                    ? 'Failed to load store details'
                    : state.message),
              );
            }

            var store = state.store!;
            var storeName = store['name'] ?? 'Unknown Store';
            var storeDescription =
                store['description'] ?? 'No description available';
            var products = state.products;

            return NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                if (scrollNotification is ScrollEndNotification &&
                    scrollNotification.metrics.pixels ==
                        scrollNotification.metrics.maxScrollExtent) {
                  // Trigger fetch more products when scrolled to the bottom
                  context
                      .read<StoreCubit>()
                      .fetchStoreDetails(storeId, isLoadMore: true);
                }
                return false;
              },
              child: ListView(
                padding: EdgeInsets.all(16.0),
                children: [
                  Image.network(
                    store['logo'] ?? 'https://via.placeholder.com/150',
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(height: 16),
                  Text(
                    storeName,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    storeDescription,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  if (products.isNotEmpty) ...[
                    Text(
                      'Products:',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Column(
                      children: products.map<Widget>((product) {
                        return Card(
                          elevation: 4,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: Image.network(
                              product['image'] ??
                                  'https://via.placeholder.com/150',
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                            title: Text(product['name'] ?? 'Unknown Product'),
                            subtitle: Text('\$${product['price'] ?? '0.00'}'),
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
                          ),
                        );
                      }).toList(),
                    ),
                    if (state.isLoading) CircularProgressIndicator(),
                    // Show a loading indicator when loading more
                  ] else
                    Text('No products available for this store.'),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
