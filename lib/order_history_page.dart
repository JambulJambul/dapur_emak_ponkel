import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({Key? key}) : super(key: key);

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFFA500),
        title: Text('Order History'),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.1,
          vertical: size.height * 0.05,
        ),
        child: ListView.builder(
          itemCount: 5,
          itemBuilder: (BuildContext context, int index) {
            final String date =
                DateFormat.yMMMMd().format(DateTime.now()).toString();
            final List<FoodItem> items = [
              FoodItem(
                name: 'Burger',
                image: 'assets/images/attachment_121740866.png',
              ),
              FoodItem(
                name: 'Pizza',
                image: 'assets/images/attachment_121740866.png',
              ),
              FoodItem(
                name: 'Sushi',
                image: 'assets/images/attachment_121740866.png',
              ),
            ];

            return SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      date,
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  for (FoodItem item in items) _buildFoodItemRow(item),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFoodItemRow(FoodItem item) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.asset(
              item.image,
              width: 70.0,
              height: 70.0,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 8.0),
        ],
      ),
    );
  }
}

class FoodItem {
  final String name;
  final String image;

  FoodItem({
    required this.name,
    required this.image,
  });
}
