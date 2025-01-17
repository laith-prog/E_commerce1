import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/CartCubit.dart';
import 'OrderFormDialog.dart';

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Fetch cart when screen is first built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartCubit>().fetchCart();
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: BlocConsumer<CartCubit, CartState>(
        listener: (context, state) {
          if (state is CartUpdated || state is CartCanceled ||
              state is CartError || state is OrderCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    (state is CartUpdated) ? state.message :
                    (state is CartCanceled) ? state.message :
                    (state is OrderCreated) ? state.message :
                    (state as CartError).message
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CartLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is CartLoaded) {
            final cartItems = state.cart['items'] ?? [];

            if (cartItems.isEmpty) {
              return Center(child: Text('Your cart is empty'));
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return Card(
                        margin: EdgeInsets.all(8.0),
                        elevation: 4,
                        child: ListTile(
                          leading: Image.network(
                            item['product']['image'] ??
                                'https://via.placeholder.com/150',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                          title: Text(item['product']['name'] ?? 'Unknown'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '\$${item['product']['price']}',
                                style: TextStyle(color: Colors.green),
                              ),
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
                                    icon: Icon(Icons.remove),
                                  ),
                                  Text('${item['quantity']}'),
                                  IconButton(
                                    onPressed: () {
                                      context.read<CartCubit>().editCartItem(
                                        item['id'],
                                        item['quantity'] + 1,
                                      );
                                    },
                                    icon: Icon(Icons.add),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              context.read<CartCubit>().deleteCartItem(item['id']);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                _buildBottomSection(context, state),
              ],
            );
          } else {
            return Center(child: Text('Failed to load cart'));
          }
        },
      ),
    );
  }

  Widget _buildBottomSection(BuildContext context, CartLoaded state) {
    return Container(
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
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '\$${state.total}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => context.read<CartCubit>().cancelCart(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: Text('Cancel Cart'),
                ),
              ),
              SizedBox(width: 10),

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
    );
  }
}