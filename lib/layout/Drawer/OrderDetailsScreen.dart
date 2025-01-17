import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/OrderDetailsCubit.dart';

class OrderDetailScreen extends StatefulWidget {
  final String token;
  final int orderId;

  const OrderDetailScreen({Key? key, required this.token, required this.orderId}) : super(key: key);

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  bool isEditing = false;
  String? updatedLocation;
  List<Map<String, dynamic>> updatedOrderItems = [];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OrderDetailsCubit()..fetchOrderDetails(widget.token, widget.orderId),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Order Details'),
        ),
        body: BlocBuilder<OrderDetailsCubit, OrderDetailsState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state.error != null) {
              return Center(child: Text("Error: ${state.error}"));
            } else if (state.order != null) {
              final order = state.order!;
              final orderItems = order['order_items'] as List<dynamic>;

              // Initialize updated items only once
              if (updatedOrderItems.isEmpty) {
                updatedOrderItems = orderItems
                    .map((item) => {
                  'id': item['id'],
                  'product_id': item['product']['id'],
                  'quantity': item['quantity'],
                  'price_at_time': item['price_at_time'],
                })
                    .toList();
              }

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: isEditing
                    ? _buildEditForm(context, order, orderItems)
                    : _buildOrderDetails(context, order, orderItems),
              );
            }
            return const Center(child: Text("No order details available."));
          },
        ),
      ),
    );
  }

  Widget _buildOrderDetails(BuildContext context, Map<String, dynamic> order, List<dynamic> orderItems) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Order ID: ${order['id']}"),
        Text("Status: ${order['status']}"),
        Text("Total Amount: \$${order['total_amount']}"),
        Text("Payment Method: ${order['payment_method']}"),
        Text("Delivery Location: ${order['delivery_location']}"),
        const SizedBox(height: 16),
        Text("Items:"),
        Expanded(
          child: ListView.builder(
            itemCount: orderItems.length,
            itemBuilder: (context, index) {
              final item = orderItems[index];
              final product = item['product'];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  leading: Image.network(
                    product['image'], // Adjust to your image fetching logic
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported),
                  ),
                  title: Text(product['name']),
                  subtitle: Text(product['description']),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Qty: ${item['quantity']}"),
                      Text("\$${item['price_at_time']}"),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              onPressed: () => context.read<OrderDetailsCubit>().cancelOrder(widget.token, widget.orderId),
              child: const Text("Cancel Order"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isEditing = true;
                  updatedLocation = order['delivery_location'];
                });
              },
              child: const Text("Edit Order"),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEditForm(BuildContext context, Map<String, dynamic> order, List<dynamic> orderItems) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          initialValue: updatedLocation ?? "",
          decoration: const InputDecoration(labelText: "Delivery Location"),
          onChanged: (value) => updatedLocation = value,
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: updatedOrderItems.length,
            itemBuilder: (context, index) {
              final item = updatedOrderItems[index];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  title: Text("Product ID: ${item['product_id']}"),
                  subtitle: Text("Price: \$${item['price_at_time']}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            if (item['quantity'] > 1) {
                              item['quantity']--;
                            }
                          });
                        },
                      ),
                      Text("${item['quantity']}"),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            item['quantity']++;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isEditing = false;
                });
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<OrderDetailsCubit>().editOrder(
                  widget.token,
                  widget.orderId,
                  updatedOrderItems,
                );
                setState(() {
                  isEditing = false;
                });
              },
              child: const Text("Save Changes"),
            ),
          ],
        ),
      ],
    );
  }
}
