import 'package:flutter/material.dart';

class MyButtonExample extends StatefulWidget {
  const MyButtonExample({Key? key}) : super(key: key);

  @override
  _MyButtonExampleState createState() => _MyButtonExampleState();
}

class _MyButtonExampleState extends State<MyButtonExample> {
  List<bool> itemStates = List.generate(5, (index) => false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text('Item $index'),
          trailing: ElevatedButton(
            onPressed: () {
              setState(() {
                itemStates[index] = !itemStates[index];
              });
              print(index);
              print(itemStates[index]);
            },
            child: Text(itemStates[index] ? 'Selected' : 'Select'),
          ),
        );
      },
    ));
  }
}
