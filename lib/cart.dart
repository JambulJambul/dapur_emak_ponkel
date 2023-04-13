import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class CartItem {
  final String name;
  int quantity;
  final double price;

  CartItem({
    required this.name,
    required this.quantity,
    required this.price,
  });
}

class _CartPageState extends State<CartPage> {
  List<CartItem> _cartItems = [
    CartItem(name: 'Item 1', quantity: 2, price: 10.0),
    CartItem(name: 'Item 2', quantity: 1, price: 15.0),
    CartItem(name: 'Item 3', quantity: 3, price: 7.5),
  ];
  String _selectedPaymentOption = 'Bank Transfer';
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double buttonWidth = size.width * 0.6;

    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
        backgroundColor: Color(0xFFFFA500),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.1,
          vertical: size.height * 0.05,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Order Date: ${DateFormat.yMMMMd().format(DateTime.now())}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            ListView.separated(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              separatorBuilder: (context, index) => Divider(),
              itemCount: _cartItems.length,
              itemBuilder: (context, index) {
                final item = _cartItems[index];

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${item.name}'),
                    Row(
                      children: [
                        Text('\$${item.price * item.quantity}'),
                        SizedBox(width: 10),
                        SizedBox(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove),
                                onPressed: () {
                                  setState(() {
                                    if (item.quantity > 1) {
                                      item.quantity--;
                                    }
                                  });
                                },
                              ),
                              Text('${item.quantity}'),
                              IconButton(
                                icon: Icon(Icons.add),
                                onPressed: () {
                                  setState(() {
                                    item.quantity++;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: size.height * 0.05),
            SizedBox(
              width: buttonWidth,
              child: ElevatedButton(
                onPressed: () {
                  (context);
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFFA500)),
                child: Text('Proceed to Payment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
