import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/ProductSearchCubit.dart';
import '../cubit/StoreSearchCubit.dart';

class SearchScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ProductSearchCubit()),
        BlocProvider(create: (context) => StoreSearchCubit()),
      ],
      child: SearchScreenContent(),
    );
  }
}

class SearchScreenContent extends StatefulWidget {
  @override
  _SearchScreenContentState createState() => _SearchScreenContentState();
}

class _SearchScreenContentState extends State<SearchScreenContent> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
      ),
      body: Column(
        children: [
          // Search Input
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Enter search query',
                border: OutlineInputBorder(),
              ),
            ),
          ),

          // Buttons for Search
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  final query = _searchController.text.trim();
                  if (query.isNotEmpty) {
                    BlocProvider.of<ProductSearchCubit>(context)
                        .searchProducts(query);
                  }
                },
                child: Text('Search Products'),
              ),
              ElevatedButton(
                onPressed: () {
                  final query = _searchController.text.trim();
                  if (query.isNotEmpty) {
                    BlocProvider.of<StoreSearchCubit>(context)
                        .searchStores(query);
                  }
                },
                child: Text('Search Stores'),
              ),
            ],
          ),

          // Results Display
          Expanded(
            child: ListView(
              children: [
                // Products Section
                BlocBuilder<ProductSearchCubit, ProductSearchState>(
                  builder: (context, state) {
                    if (state.isLoading) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (state.error.isNotEmpty) {
                      return Center(child: Text(state.error));
                    }

                    if (state.products.isEmpty) {
                      return Center(child: Text('No products found'));
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Products',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: state.products.length,
                          itemBuilder: (context, index) {
                            var product = state.products[index];
                            return ListTile(
                              leading: product['image'] != null
                                  ? Image.network(product['image'])
                                  : null,
                              title: Text(product['name']),
                              subtitle: Text('\$${product['price']}'),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),

                // Stores Section
                BlocBuilder<StoreSearchCubit, StoreSearchState>(
                  builder: (context, state) {
                    if (state.isLoading) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (state.error.isNotEmpty) {
                      return Center(child: Text(state.error));
                    }

                    if (state.stores.isEmpty) {
                      return Center(child: Text('No stores found'));
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Stores',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: state.stores.length,
                          itemBuilder: (context, index) {
                            var store = state.stores[index];
                            return ListTile(
                              leading: store['logo'] != null
                                  ? Image.network(store['logo'])
                                  : null,
                              title: Text(store['name']),
                              subtitle: Text(store['description']),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
