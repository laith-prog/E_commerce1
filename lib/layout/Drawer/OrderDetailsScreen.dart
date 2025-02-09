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
  String? updatedPaymentMethod;
  String? updatedTransactionId;
  List<Map<String, dynamic>> updatedOrderItems = [];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OrderDetailsCubit()..fetchOrderDetails(widget.token, widget.orderId),
      child: Scaffold(
        backgroundColor: Color(0xFFFAFAFA), // Off White background
        appBar: AppBar(
          title: const Text(
            'Order Details',
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
        body: BlocBuilder<OrderDetailsCubit, OrderDetailsState>(
          builder: (context, state) {
            if (state.isLoading) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF47C7C)), // Warm Pink
                ),
              );
            } else if (state.error != null) {
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
                      "Error: ${state.error}",
                      style: TextStyle(
                        color: Color(0xFFD64A4A), // Deep Pink
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => context.read<OrderDetailsCubit>().fetchOrderDetails(widget.token, widget.orderId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFF47C7C), // Warm Pink
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "Retry",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
            } else if (state.order != null) {
              final order = state.order!;
              final orderItems = order['order_items'] as List<dynamic>;

              // Initialize updated values only once
              if (updatedOrderItems.isEmpty) {
                updatedOrderItems = orderItems
                    .map((item) => {
                  'id': item['id'],
                  'product_id': item['product']['id'],
                  'quantity': item['quantity'],
                  'price_at_time': item['price_at_time'],
                })
                    .toList();
                updatedLocation = order['delivery_location'];
                updatedPaymentMethod = order['payment_method'];
                updatedTransactionId = order['transaction_id'];
              }

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: isEditing
                    ? _buildEditForm(context, order, orderItems)
                    : _buildOrderDetails(context, order, orderItems),
              );
            }
            return Center(
              child: Text(
                "No order details available.",
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF4F4F4F), // Charcoal Gray
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderDetails(BuildContext context, Map<String, dynamic> order, List<dynamic> orderItems) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Order ID: ${order['id']}",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4F4F4F), // Charcoal Gray
          ),
        ),
        SizedBox(height: 8),
        Text(
          "Status: ${order['status']}",
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF4F4F4F), // Charcoal Gray
          ),
        ),
        SizedBox(height: 8),
        Text(
          "Total Amount: \$${order['total_amount']}",
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF4F4F4F), // Charcoal Gray
          ),
        ),
        SizedBox(height: 8),
        Text(
          "Payment Method: ${order['payment_method']}",
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF4F4F4F), // Charcoal Gray
          ),
        ),
        SizedBox(height: 8),
        Text(
          "Transaction ID: ${order['transaction_id']}",
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF4F4F4F), // Charcoal Gray
          ),
        ),
        SizedBox(height: 8),
        Text(
          "Delivery Location: ${order['delivery_location']}",
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF4F4F4F), // Charcoal Gray
          ),
        ),
        SizedBox(height: 16),
        Text(
          "Items:",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4F4F4F), // Charcoal Gray
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: orderItems.length,
            itemBuilder: (context, index) {
              final item = orderItems[index];
              final product = item['product'];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 3,
                shadowColor: Color(0xFFE0E0E0).withOpacity(0.5), // Light Gray shadow
                child: ListTile(
                  leading: Image.network(
                    'http://192.168.45.88:8000/storage/' +product['image'], // Adjust to your image fetching logic
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.image_not_supported,
                      color: Color(0xFF4F4F4F), // Charcoal Gray
                    ),
                  ),
                  title: Text(
                    product['name'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4F4F4F), // Charcoal Gray
                    ),
                  ),
                  subtitle: Text(
                    product['description'],
                    style: TextStyle(
                      color: Color(0xFF4F4F4F).withOpacity(0.7), // Charcoal Gray with opacity
                    ),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Qty: ${item['quantity']}",
                        style: TextStyle(
                          color: Color(0xFF4F4F4F), // Charcoal Gray
                        ),
                      ),
                      Text(
                        "\$${item['price_at_time']}",
                        style: TextStyle(
                          color: Color(0xFF4F4F4F), // Charcoal Gray
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              onPressed: () => context.read<OrderDetailsCubit>().cancelOrder(widget.token, widget.orderId),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFD64A4A), // Deep Pink
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                "Cancel Order",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isEditing = true;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFF47C7C), // Warm Pink
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                "Edit Order",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
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
          decoration: InputDecoration(
            labelText: "Delivery Location",
            labelStyle: TextStyle(color: Color(0xFF4F4F4F)), // Charcoal Gray
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onChanged: (value) => updatedLocation = value,
        ),
        SizedBox(height: 16),
        TextFormField(
          initialValue: updatedPaymentMethod ?? "",
          decoration: InputDecoration(
            labelText: "Payment Method",
            labelStyle: TextStyle(color: Color(0xFF4F4F4F)), // Charcoal Gray
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onChanged: (value) => updatedPaymentMethod = value,
        ),
        SizedBox(height: 16),
        TextFormField(
          initialValue: updatedTransactionId ?? "",
          decoration: InputDecoration(
            labelText: "Transaction ID",
            labelStyle: TextStyle(color: Color(0xFF4F4F4F)), // Charcoal Gray
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onChanged: (value) => updatedTransactionId = value,
        ),
        SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: updatedOrderItems.length,
            itemBuilder: (context, index) {
              final item = updatedOrderItems[index];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 3,
                shadowColor: Color(0xFFE0E0E0).withOpacity(0.5), // Light Gray shadow
                child: ListTile(
                  title: Text(
                    "Product ID: ${item['product_id']}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4F4F4F), // Charcoal Gray
                    ),
                  ),
                  subtitle: Text(
                    "Price: \$${item['price_at_time']}",
                    style: TextStyle(
                      color: Color(0xFF4F4F4F).withOpacity(0.7), // Charcoal Gray with opacity
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.remove,
                          color: Color(0xFFF47C7C), // Warm Pink
                        ),
                        onPressed: () {
                          setState(() {
                            if (item['quantity'] > 1) {
                              item['quantity']--;
                            }
                          });
                        },
                      ),
                      Text(
                        "${item['quantity']}",
                        style: TextStyle(
                          color: Color(0xFF4F4F4F), // Charcoal Gray
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.add,
                          color: Color(0xFFF47C7C), // Warm Pink
                        ),
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
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isEditing = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4F4F4F), // Charcoal Gray
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                "Cancel",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFF47C7C), // Warm Pink
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                "Save Changes",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }
}