import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'payment_page.dart';

class CartPage extends StatefulWidget {
  final List<CartItem> cartItems;
  final String orderType;
  final DateTime deliveryDay;
  final int? numberOfDays;
  // ignore: prefer_const_constructors_in_immutables
  CartPage(
      {Key? key,
      required this.cartItems,
      required this.orderType,
      required this.deliveryDay,
      this.numberOfDays})
      : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class CartItem {
  final String label;
  final String imgUrl;
  final String itemDesc;
  int quantity;
  int price;
  CartItem({
    required this.imgUrl,
    required this.itemDesc,
    required this.label,
    required this.quantity,
    required this.price,
  });
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
  int bulkQuantity = 10;

  List<CartItem> _cartItems = [];
  @override
  void initState() {
    super.initState();
    _cartItems = widget.cartItems;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double buttonWidth = size.width * 0.6;
    DateTime lastDate =
        widget.deliveryDay.add(Duration(days: widget.numberOfDays ?? 0));

    return Scaffold(
        appBar: AppBar(
          title: const Text('Cart'),
          backgroundColor: const Color(0xFFFFA500),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.1,
              vertical: size.height * 0.05,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
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
                                  if (widget.orderType == "daily") ...[
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 8.0),
                                        Text(
                                          'Rp${item.price * item.quantity}',
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
                                                  if (item.quantity > 0) {
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
                                    )
                                  ] else ...[
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 8.0),
                                        Text(
                                          'Rp${item.price} x ${item.quantity}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 8.0),
                                        Text(
                                          '= Rp${item.price * item.quantity}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    )
                                  ]
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
                if (widget.orderType == "event")
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Number of orders: "),
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            if (bulkQuantity > 10) {
                              bulkQuantity--;
                              for (final item in _cartItems) {
                                item.quantity = bulkQuantity;
                              }
                            }
                          });

                          if (bulkQuantity == 10) {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return const AlertDialog(
                                  content:
                                      Text("10 is the minimum amount of order"),
                                );
                              },
                            );
                          }
                        },
                      ),
                      Text(
                        '$bulkQuantity',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            bulkQuantity++;
                            for (final item in _cartItems) {
                              item.quantity = bulkQuantity;
                            }
                          });
                        },
                      ),
                    ],
                  ),
                if (widget.numberOfDays == null) ...[
                  Text(
                      'Order Date: ${DateFormat.yMMMMd().format(widget.deliveryDay)}'),
                  SizedBox(height: size.height * 0.02),
                  Text('Total Price: Rp${_calculateTotalPrice()}'),
                ],
                if (widget.numberOfDays != null) ...[
                  Text(
                      'First Date: ${DateFormat.yMMMMd().format(widget.deliveryDay)}'),
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  Text('Last Date: ${DateFormat.yMMMMd().format(lastDate)}'),
                  SizedBox(height: size.height * 0.02),
                  Text('Total Price: Rp${_calculateTotalMultiPrice()}'),
                ],
                SizedBox(height: size.height * 0.05),
                SizedBox(
                  width: buttonWidth,
                  child: ElevatedButton(
                    onPressed: () {
                      if (widget.numberOfDays == null) {
                        [
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => PaymentPage(
                                  cartItems: _cartItems,
                                  totalPrice: _calculateTotalPrice(),
                                  deliveryDay: widget.deliveryDay,
                                  orderType: widget.orderType),
                            ),
                          )
                        ];
                      } else {
                        [
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => PaymentPage(
                                  cartItems: _cartItems,
                                  totalPrice: _calculateTotalMultiPrice(),
                                  deliveryDay: widget.deliveryDay,
                                  numberOfDays: widget.numberOfDays,
                                  orderType: widget.orderType),
                            ),
                          )
                        ];
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFA500)),
                    child: const Text('Proceed to Payment'),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  int _calculateTotalPrice() {
    int totalPrice = 0;
    for (final item in _cartItems) {
      totalPrice += item.price * item.quantity;
    }
    return totalPrice;
  }

  int _calculateTotalMultiPrice() {
    int totalPrice = 0;
    for (final item in _cartItems) {
      totalPrice += item.price * item.quantity * ((widget.numberOfDays! + 1));
    }
    return totalPrice;
  }
}
