import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For input formatters
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
            SnackBar(
              content: Text(state.message),
              backgroundColor: Color(0xFFF2C94C), // Muted Gold
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
      child: AlertDialog(
        backgroundColor: Color(0xFFFFF9F4), // Soft Beige background
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Rounded corners for the dialog
        ),
        title: Text(
          'Enter Order Details',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4F4F4F), // Charcoal Gray
            fontFamily: 'Roboto', // Replace with your custom font
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _paymentMethodController,
                decoration: InputDecoration(
                  labelText: 'Payment Method',
                  labelStyle: TextStyle(
                    color: Color(0xFF4F4F4F), // Charcoal Gray
                    fontFamily: 'Roboto', // Replace with your custom font
                  ),
                  hintText: 'Enter payment method',
                  prefixIcon: Icon(
                    Icons.credit_card,
                    color: Color(0xFF4F4F4F), // Charcoal Gray
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFFF47C7C), // Warm Pink
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _transactionIdController,
                keyboardType: TextInputType.number, // Numeric keyboard
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // Only allow digits
                ],
                decoration: InputDecoration(
                  labelText: 'Transaction ID (Optional)',
                  labelStyle: TextStyle(
                    color: Color(0xFF4F4F4F), // Charcoal Gray
                    fontFamily: 'Roboto', // Replace with your custom font
                  ),
                  hintText: 'Enter transaction ID if available',
                  prefixIcon: Icon(
                    Icons.qr_code,
                    color: Color(0xFF4F4F4F), // Charcoal Gray
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFFF47C7C), // Warm Pink
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Color(0xFF4F4F4F), // Charcoal Gray
                fontFamily: 'Roboto', // Replace with your custom font
              ),
            ),
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
                        backgroundColor: Color(0xFFD64A4A), // Deep Pink
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFF2C94C), // Muted Gold
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: state is CartLoading
                    ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : Text(
                  'Confirm Order',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Roboto', // Replace with your custom font
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}