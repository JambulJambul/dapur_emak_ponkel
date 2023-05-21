import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'payment_page.dart';

class CartPage extends StatefulWidget {
  List<CartItem> cartItems = [];
  CartPage({Key? key, required this.cartItems}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class CartItem {
  final String label;
  final String imgUrl;
  final String itemDesc;
  int quantity;
  var price;
  DateTime deliveryDate;
  CartItem(
      {required this.imgUrl,
      required this.itemDesc,
      required this.label,
      required this.quantity,
      required this.price,
      required this.deliveryDate});
  Map<String, dynamic> toMap() {
    return {
      'name': label,
      'price': price,
      'quantity': quantity,
      'imgUrl': imgUrl,
    };
  }
}

class _CartPageState extends State<CartPage> {
  List<CartItem> _cartItems = [];
  @override
  void initState() {
    super.initState();
    _cartItems = widget.cartItems;
  }

  final String _selectedPaymentOption = 'Bank Transfer';
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double buttonWidth = size.width * 0.6;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        backgroundColor: const Color(0xFFFFA500),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.1,
          vertical: size.height * 0.05,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            ListView.separated(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              separatorBuilder: (context, index) => const Divider(),
              itemCount: _cartItems.length,
              itemBuilder: (context, index) {
                final item = _cartItems[index];

                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            item.imgUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.label,
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                'RM ${item.price * item.quantity}',
                                style: const TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed: () {
                                      setState(() {
                                        if (item.quantity > 1) {
                                          item.quantity--;
                                        }
                                      });
                                    },
                                  ),
                                  Text(
                                    '${item.quantity}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () {
                                      setState(() {
                                        item.quantity++;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: size.height * 0.05),
            Text(
                'Order Date: ${DateFormat.yMMMMd().format(_cartItems[0].deliveryDate)}'),
            SizedBox(height: size.height * 0.02),
            Text('Total Price: RM${_calculateTotalPrice()}'),
            SizedBox(height: size.height * 0.05),
            SizedBox(
              width: buttonWidth,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PaymentPage(
                          cartItems: _cartItems,
                          totalPrice: _calculateTotalPrice()),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFA500)),
                child: const Text('Proceed to Payment'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateTotalPrice() {
    double totalPrice = 0;
    for (final item in _cartItems) {
      totalPrice += item.price * item.quantity;
    }
    return totalPrice;
  }
}
