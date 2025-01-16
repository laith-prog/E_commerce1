import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/ProductDetailsCubit.dart';
import '../cubit/AddToCartCubit.dart';
import '../stores/StoreDetailsScreen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String productId;

  ProductDetailsScreen({required this.productId});

  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int quantity = 1;  // Initial quantity

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProductDetailsCubit()..fetchProductDetails(widget.productId),
      child: BlocBuilder<ProductDetailsCubit, ProductDetailsState>(
        builder: (context, state) {
          if (state.isLoading) {
            return Scaffold(
              appBar: AppBar(title: Text('Product Details')),
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (!state.isSuccess || state.productDetails == null) {
            return Scaffold(
              appBar: AppBar(title: Text('Product Details')),
              body: Center(child: Text(state.message)),
            );
          }

          final product = state.productDetails!;
          final store = product['store']; // Store details are inside the product object

          return Scaffold(
            appBar: AppBar(title: Text(product['name'] ?? 'Product Details')),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Image
                    Center(
                      child: Image.network(
                        product['image'] ?? 'https://via.placeholder.com/300',
                        height: 300,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: 16),

                    // Product Name
                    Text(
                      product['name'] ?? 'Unknown Product',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),

                    // Product Price
                    Text(
                      '\$${product['price']}',
                      style: TextStyle(fontSize: 20, color: Colors.green),
                    ),
                    SizedBox(height: 16),

                    // Product Description
                    Text(
                      product['description'] ?? 'No description available',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 16),

                    // Store Details Section
                    if (store != null) ...[
                      Text(
                        'Store Details:',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Store Name: ${store['name'] ?? 'Unknown Store'}',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Location: ${store['location'] ?? 'No location available'}',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Store Description: ${store['description'] ?? 'No description available'}',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 16),

                      // Button or Gesture to Navigate to Store Details
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to StoreDetailsScreen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StoreDetailsScreen(storeId: store['id'].toString()),
                            ),
                          );
                        },
                        child: Text('View Store Details'),
                      ),
                    ],

                    // Counter for Quantity
                    SizedBox(height: 16),
                    Text(
                      'Quantity: $quantity',
                      style: TextStyle(fontSize: 20),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              if (quantity > 1) {
                                quantity--; // Decrement the quantity
                              }
                            });
                          },
                          icon: Icon(Icons.remove),
                        ),
                        Text(
                          '$quantity',
                          style: TextStyle(fontSize: 20),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              quantity++; // Increment the quantity
                            });
                          },
                          icon: Icon(Icons.add),
                        ),
                      ],
                    ),

                    // Add to Cart Button
                    SizedBox(height: 16),
                    BlocProvider(
                      create: (context) => AddToCartCubit(),
                      child: BlocConsumer<AddToCartCubit, AddToCartState>(
                        listener: (context, addToCartState) {
                          if (addToCartState.isSuccess) {
                            // Show a success message when the product is added to the cart
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(addToCartState.message)),
                            );
                          } else if (addToCartState.message.isNotEmpty) {
                            // Show error message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(addToCartState.message)),
                            );
                          }
                        },
                        builder: (context, addToCartState) {
                          return ElevatedButton(
                            onPressed: () {
                              // Ensure productId is passed as String and quantity as int
                              context.read<AddToCartCubit>().addToCart(product['id'].toString(), quantity); // Convert productId to String
                            },
                            child: addToCartState.isLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text('Add to Cart'),
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
      ),
    );
  }
}
