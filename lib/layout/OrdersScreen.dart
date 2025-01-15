import 'package:flutter/material.dart';

class OrdersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Orders')),
      body: ListView.builder(
        itemCount: 5,  // Number of dummy orders
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Order #${index + 1}'),
            subtitle: Text('This is a dummy order item'),
            leading: Icon(Icons.shopping_cart),
          );
        },
      ),
    );
  }
}
