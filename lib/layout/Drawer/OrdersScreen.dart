import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/OrdersCubit.dart';
import 'OrderDetailsScreen.dart';

class OrdersScreen extends StatelessWidget {
  final String token;

  OrdersScreen({required this.token});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OrdersCubit()..fetchOrders(token),
      child: Scaffold(
        backgroundColor: Color(0xFFFAFAFA), // Off White background
        appBar: AppBar(
          title: Text(
            'My Orders',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white, // White text for contrast
            ),
          ),
          backgroundColor: Color(0xFFF47C7C), // Warm Pink
          elevation: 10,
          shadowColor: Color(0xFFD64A4A).withOpacity(0.5), // Deep Pink shadow
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
        ),
        body: BlocBuilder<OrdersCubit, OrdersState>(
          builder: (context, state) {
            if (state.isLoading) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF47C7C)), // Warm Pink
                ),
              );
            }

            if (state.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Color(0xFFD64A4A), // Deep Pink
                      size: 50,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Error: ${state.error!}',
                      style: TextStyle(color: Color(0xFFD64A4A), fontSize: 18), // Deep Pink
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => context.read<OrdersCubit>().fetchOrders(token),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFF47C7C), // Warm Pink
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Retry',
                        style: TextStyle(fontSize: 16, color: Colors.white), // White text
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state.orders == null || state.orders!.isEmpty) {
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
                      'No orders found.',
                      style: TextStyle(fontSize: 18, color: Color(0xFF4F4F4F)), // Charcoal Gray
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<OrdersCubit>().fetchOrders(token);
              },
              color: Color(0xFFF47C7C), // Warm Pink
              child: ListView.builder(
                padding: EdgeInsets.all(10),
                itemCount: state.orders!.length,
                itemBuilder: (context, index) {
                  final order = state.orders![index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    shadowColor: Color(0xFFE0E0E0).withOpacity(0.5), // Light Gray shadow
                    child: InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderDetailScreen(
                              token: token,
                              orderId: order['id'],
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.shopping_bag,
                              color: Color(0xFFF47C7C), // Warm Pink
                              size: 30,
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Order #${order['id']}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF4F4F4F), // Charcoal Gray
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    'Total: \$${order['total_amount']}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF4F4F4F).withOpacity(0.7), // Charcoal Gray with opacity
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Color(0xFFF47C7C), // Warm Pink
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}