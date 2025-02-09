import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../Product/ProductScreen.dart';
import '../cubit/ProductSearchCubit.dart';
import '../cubit/StoreSearchCubit.dart';
import '../stores/StoreDetailsScreen.dart';

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
  bool _hasSearched = false; // Flag to track if the user has pressed a search button
  String _selectedSearchType = ''; // Track which category the user is searching (Product or Store)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAFAFA), // Off White background
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          children: [
            // Search Input Field
            _buildSearchInput(),
            SizedBox(height: 20),
            // Search Buttons
            _buildSearchButtons(),
            SizedBox(height: 20),
            // Results
            Expanded(
              child: _hasSearched
                  ? _selectedSearchType == 'products'
                  ? _buildProductResults()
                  : _buildStoreResults()
                  : Container(), // Show results based on the selected category
            ),
          ],
        ),
      ),
    );
  }

  // Build the search input field
  Widget _buildSearchInput() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Enter search query',
        prefixIcon: Icon(Icons.search, color: Color(0xFFF47C7C)), // Warm Pink
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Color(0xFFE0E0E0)), // Light Gray
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Color(0xFFF47C7C)), // Warm Pink
        ),
      ),
    );
  }

  // Build search buttons
  Widget _buildSearchButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildSearchButton(
          text: 'Search Products',
          onPressed: () {
            final query = _searchController.text.trim();
            if (query.isNotEmpty) {
              BlocProvider.of<ProductSearchCubit>(context).searchProducts(query);
              setState(() {
                _hasSearched = true; // Set flag to true once search is performed
                _selectedSearchType = 'products'; // Set the selected search type to products
              });
            }
          },
        ),
        _buildSearchButton(
          text: 'Search Stores',
          onPressed: () {
            final query = _searchController.text.trim();
            if (query.isNotEmpty) {
              BlocProvider.of<StoreSearchCubit>(context).searchStores(query);
              setState(() {
                _hasSearched = true; // Set flag to true once search is performed
                _selectedSearchType = 'stores'; // Set the selected search type to stores
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildSearchButton({required String text, required VoidCallback onPressed}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFF47C7C), // Warm Pink
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  // Build results for products
  // Build results for products
// Build results for products
  Widget _buildProductResults() {
    return BlocBuilder<ProductSearchCubit, ProductSearchState>(
      builder: (context, state) {
        if (state.isLoading && state.products.isEmpty) {
          // Show a loading indicator while loading products for the first time
          return Center(child: CircularProgressIndicator());
        }

        if (state.error.isNotEmpty) {
          // Show error message if there is any error
          return Center(child: Text(state.error));
        }

        if (state.products.isEmpty) {
          // Show no results message if no products are found
          return Center(child: Text('No results found for "${_searchController.text}"'));
        }

        // Handle the product list display
        return NotificationListener<ScrollNotification>(
          onNotification: (scrollNotification) {
            if (scrollNotification is ScrollEndNotification &&
                scrollNotification.metrics.pixels == scrollNotification.metrics.maxScrollExtent) {
              // User has reached the bottom, trigger "load more"
              if (state.hasMore) {
                // Only fetch more if there are more products
                String query = _searchController.text.trim();
                context.read<ProductSearchCubit>().searchProducts(query, isLoadMore: true);
              }
            }
            return false;
          },
          child: ListView.builder(
            itemCount: state.products.length + (state.isLoading ? 1 : 0), // Show loading at the bottom if isLoading is true
            itemBuilder: (context, index) {
              if (index == state.products.length) {
                // Show loading indicator at the bottom while loading more
                return Center(child: CircularProgressIndicator());
              }

              var product = state.products[index];
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
                child: Row(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      margin: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[200],
                        image: 'http://192.168.45.88:8000/storage/' +product['image'] != null
                            ? DecorationImage(
                          image: NetworkImage('http://192.168.45.88:8000/storage/' +product['image']),
                          fit: BoxFit.cover,
                        )
                            : null,
                      ),
                      child: 'http://192.168.45.88:8000/storage/' + product['image'] == null
                          ? Icon(Icons.image_not_supported, color: Colors.grey)
                          : null,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product['name'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 5),
                          Text(
                            '\$${product['price']}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFF47C7C),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }



  Widget _buildStoreResults() {
    return BlocBuilder<StoreSearchCubit, StoreSearchState>(
      builder: (context, state) {
        if (state.isLoading && state.stores.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }

        if (state.error.isNotEmpty) {
          return Center(child: Text(state.error));
        }

        if (state.stores.isEmpty) {
          return Center(child: Text('No results found for "${_searchController.text}"'));
        }

        return NotificationListener<ScrollNotification>(
          onNotification: (scrollNotification) {
            if (scrollNotification is ScrollEndNotification &&
                scrollNotification.metrics.pixels == scrollNotification.metrics.maxScrollExtent) {
              // User has reached the bottom, trigger "load more"
              context.read<StoreSearchCubit>().searchStores(
                _searchController.text.trim(),
                isLoadMore: true,
              );
            }
            return false;
          },
          child: ListView.builder(
            itemCount: state.stores.length + (state.isLoading ? 1 : 0), // Show loading at the bottom if isLoading is true
            itemBuilder: (context, index) {
              if (index == state.stores.length) {
                // Show loading indicator at the bottom while loading more
                return Center(child: CircularProgressIndicator());
              }

              var store = state.stores[index];
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
                child: Row(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      margin: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[200],
                      ),
                      child: 'http://192.168.45.88:8000/storage/' + store['image'] != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          'http://192.168.45.88:8000/storage/' + store['image'],
                          fit: BoxFit.cover,
                          width: 70,
                          height: 70,
                        ),
                      )
                          : Container(), // Empty container if no logo is available
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            store['name'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 5),
                          Text(
                            store['description'],
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF888888),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
