import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/CartCubit.dart';
import '../layout/OrderFormDialog.dart';

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF9F4),  // Soft Beige background
      body: BlocProvider(
        create: (context) => CartCubit()..fetchCart(),
        child: BlocConsumer<CartCubit, CartState>(
          listener: (context, state) {
            if (state is CartUpdated) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            } else if (state is CartCanceled) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            } else if (state is CartError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            if (state is CartLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is CartLoaded) {
              final cartItems = state.cart['items'] ?? [];

              if (cartItems.isEmpty) {
                return Center(
                  child: Text(
                    'Your cart is empty',
                    style: TextStyle(fontSize: 22, color: Color(0xFF4F4F4F)), // Charcoal Gray
                  ),
                );
              }

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final item = cartItems[index];
                        return GestureDetector(
                          onTap: () {
                            // Add animation or tap functionality here
                          },
                          child: Card(
                            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                            elevation: 12,  // Increased elevation for more depth
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18), // Rounded corners
                            ),
                            color: Colors.white,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade300,
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: EdgeInsets.all(16.0),
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Stack(
                                    children: [
                                      Image.asset(
                                          'assets/logo_transparent.png'
                                      ),
                                      // Add gradient overlay to the image
                                      Container(
                                        width: 80,  // Increased width
                                        height: 80, // Increased height
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.black.withOpacity(0.4),
                                              Colors.transparent
                                            ],
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                title: Text(
                                  item['product']['name'] ?? 'Unknown Product',
                                  style: TextStyle(
                                    fontSize: 18,  // Increased font size for title
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF4F4F4F), // Charcoal Gray
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '\$${item['product']['price']}',
                                      style: TextStyle(
                                        fontSize: 16,  // Increased font size for price
                                        color: Color(0xFFF2C94C), // Muted Gold for price
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            if (item['quantity'] > 1) {
                                              context.read<CartCubit>().editCartItem(
                                                item['id'],
                                                item['quantity'] - 1,
                                              );
                                            }
                                          },
                                          icon: Icon(Icons.remove, size: 30, color: Color(0xFF4F4F4F)), // Increased size
                                        ),
                                        Text(
                                          '${item['quantity']}',
                                          style: TextStyle(
                                            fontSize: 22, // Increased font size for quantity
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            context.read<CartCubit>().editCartItem(
                                              item['id'],
                                              item['quantity'] + 1,
                                            );
                                          },
                                          icon: Icon(Icons.add, size: 30, color: Color(0xFF4F4F4F)), // Increased size
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete, size: 28, color: Colors.red), // Increased size
                                  onPressed: () {
                                    context.read<CartCubit>().deleteCartItem(item['id']);
                                  },
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total:',
                              style: TextStyle(
                                fontSize: 22,  // Increased font size for total
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4F4F4F), // Charcoal Gray
                              ),
                            ),
                            Text(
                              '\$${state.total}',  // Directly access the total
                              style: TextStyle(
                                fontSize: 22,  // Increased font size for total value
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFF2C94C), // Muted Gold
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  context.read<CartCubit>().cancelCart();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFFF47C7C),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16), // Rounded corners
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: Text(
                                  'Cancel Cart',
                                  style: TextStyle(
                                    color: Color(0xFF4F4F4F),
                                    fontSize: 20,  // Increased font size for button
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10,),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => BlocProvider.value(
                                      value: context.read<CartCubit>(), // Pass the existing CartCubit
                                      child: OrderFormDialog(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                                child: Text('Create Order'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            } else {
              return Center(
                child: Text(
                  'Failed to load cart',
                  style: TextStyle(fontSize: 22, color: Color(0xFF4F4F4F)), // Charcoal Gray
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
