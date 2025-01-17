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
        appBar: AppBar(
          title: Text('My Orders'),
          backgroundColor: Colors.teal,
        ),
        body: BlocBuilder<OrdersCubit, OrdersState>(
          builder: (context, state) {
            if (state.isLoading) {
              return Center(child: CircularProgressIndicator());
            }

            if (state.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: ${state.error!}',
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => context.read<OrdersCubit>().fetchOrders(token),
                      child: Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state.orders == null || state.orders!.isEmpty) {
              return Center(
                child: Text(
                  'No orders found.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<OrdersCubit>().fetchOrders(token);
              },
              child: ListView.builder(
                itemCount: state.orders!.length,
                itemBuilder: (context, index) {
                  final order = state.orders![index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 3,
                    child: ListTile(
                      title: Text(
                        'Order #${order['id']}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Total: \$${order['total_amount']}'),
                      trailing: Icon(Icons.arrow_forward_ios, color: Colors.teal),
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
