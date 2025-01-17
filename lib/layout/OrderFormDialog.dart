import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/CartCubit.dart';

class OrderFormDialog extends StatefulWidget {
  @override
  _OrderFormDialogState createState() => _OrderFormDialogState();
}

class _OrderFormDialogState extends State<OrderFormDialog> {
  final _paymentMethodController = TextEditingController();
  final _transactionIdController = TextEditingController();

  @override
  void dispose() {
    _paymentMethodController.dispose();
    _transactionIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CartCubit, CartState>(
      listener: (context, state) {
        if (state is OrderCreated) {
          Navigator.of(context).pop(); // Close dialog on successful order creation
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is CartError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: AlertDialog(
        title: Text('Enter Order Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _paymentMethodController,
                decoration: InputDecoration(
                  labelText: 'Payment Method',
                  hintText: 'Enter payment method',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _transactionIdController,
                decoration: InputDecoration(
                  labelText: 'Transaction ID (Optional)',
                  hintText: 'Enter transaction ID if available',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          BlocBuilder<CartCubit, CartState>(
            builder: (context, state) {
              return ElevatedButton(
                onPressed: state is CartLoading
                    ? null
                    : () {
                  if (_paymentMethodController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please enter payment method'),
                      ),
                    );
                    return;
                  }

                  context.read<CartCubit>().createOrder(
                    _paymentMethodController.text,
                    _transactionIdController.text.isEmpty
                        ? null
                        : _transactionIdController.text,
                  );
                },
                child: state is CartLoading
                    ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : Text('Confirm Order'),
              );
            },
          ),
        ],
      ),
    );
  }
}