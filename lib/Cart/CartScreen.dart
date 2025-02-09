import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/CartCubit.dart';
import '../layout/OrderFormDialog.dart';

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF9F4), // Soft Beige background
      body: BlocProvider(
        create: (context) => CartCubit()..fetchCart(),
        child: BlocConsumer<CartCubit, CartState>(
          listener: (context, state) {
            if (state is CartUpdated) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Color(0xFFF2C94C), // Muted Gold
                ),
              );
            } else if (state is CartCanceled) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Color(0xFFF47C7C), // Warm Pink
                ),
              );
            } else if (state is CartError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Color(0xFFD64A4A), // Deep Pink
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is CartLoading) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF47C7C)), // Warm Pink
                ),
              );
            } else if (state is CartLoaded) {
              final cartItems = state.cart['items'] ?? [];

              if (cartItems.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 60,
                        color: Color(0xFF4F4F4F), // Charcoal Gray
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Your cart is empty',
                        style: TextStyle(
                          fontSize: 22,
                          color: Color(0xFF4F4F4F), // Charcoal Gray
                        ),
                      ),
                    ],
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
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
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
                                      Image.network(
                                        'http://192.168.45.88:8000/storage/' + item['product']['image'],
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      ),
                                      Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.black.withOpacity(0.4),
                                              Colors.transparent,
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
                                    fontSize: 18,
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
                                        fontSize: 16,
                                        color: Color(0xFFF2C94C), // Muted Gold
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
                                          icon: Icon(
                                            Icons.remove,
                                            size: 30,
                                            color: Color(0xFF4F4F4F), // Charcoal Gray
                                          ),
                                        ),
                                        Text(
                                          '${item['quantity']}',
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF4F4F4F), // Charcoal Gray
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            context.read<CartCubit>().editCartItem(
                                              item['id'],
                                              item['quantity'] + 1,
                                            );
                                          },
                                          icon: Icon(
                                            Icons.add,
                                            size: 30,
                                            color: Color(0xFF4F4F4F), // Charcoal Gray
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    size: 28,
                                    color: Color(0xFFD64A4A), // Deep Pink
                                  ),
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
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4F4F4F), // Charcoal Gray
                              ),
                            ),
                            Text(
                              '\$${state.total}',
                              style: TextStyle(
                                fontSize: 22,
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
                                  backgroundColor: Color(0xFFD64A4A), // Deep Pink
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: Text(
                                  'Cancel Cart',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => BlocProvider.value(
                                      value: context.read<CartCubit>(),
                                      child: OrderFormDialog(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFFF2C94C), // Muted Gold
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: Text(
                                  'Create Order',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
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
                  style: TextStyle(
                    fontSize: 22,
                    color: Color(0xFF4F4F4F), // Charcoal Gray
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}