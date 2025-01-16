import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/CartCubit.dart';

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        if (state.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        if (state.products.isEmpty) {
          return Center(child: Text('Your cart is empty.'));
        }

        return ListView.builder(
          itemCount: state.products.length,
          itemBuilder: (context, index) {
            var product = state.products[index];
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: ListTile(
                leading: Image.network(product['image'] ?? 'https://via.placeholder.com/150'),
                title: Text(product['name'] ?? 'Unknown Product'),
                subtitle: Text('\$${product['price']}'),
                trailing: IconButton(
                  icon: Icon(Icons.remove_circle_outline),
                  onPressed: () {
                    // Handle removing the product from the cart if needed
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
