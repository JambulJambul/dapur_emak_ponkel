import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'home_page.dart';
import 'web_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dapur_emak_ponkel/cart.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'api/api_base_helper.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class PaymentPage extends StatefulWidget {
  final List<CartItem> cartItems;
  final double totalPrice;
  final DateTime deliveryDay;
  const PaymentPage(
      {Key? key,
      required this.cartItems,
      required this.totalPrice,
      required this.deliveryDay})
      : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

ApiBaseHelper api = ApiBaseHelper();
final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;
List<CartItem> _cartItems = [];

class _PaymentPageState extends State<PaymentPage> {
  String _selectedPaymentOption = 'Bank Transfer';
  final firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  final List<String> _paymentOptions = [
    'Bank Transfer',
    'E-Wallet',
  ];

  Future<void> _uploadFileFirebase(File file) async {
    try {
      User? user = _auth.currentUser;
      _cartItems = widget.cartItems;
      String fileName = Path.basename(file.path);
      Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('payment/bank_transfer/$fileName');
      UploadTask uploadTask = ref.putFile(file);

      await uploadTask.whenComplete(() => null);

      List<Map<String, dynamic>> cartItemsData = [];
      for (var cartItem in _cartItems) {
        cartItemsData.add(cartItem.toMap());
      }

      String downloadUrl = await ref.getDownloadURL();
      var orderId = DateTime.now().millisecondsSinceEpoch.toString();
      await _firestore.collection('payment').add({
        'amount': widget.totalPrice,
        'orderId': orderId,
        'paymentType': "upload",
        'paymentUrl': downloadUrl,
        'uid': user?.uid,
        'deliveryDate':
            DateFormat.yMMMMd().format(widget.deliveryDay).toString(),
        'cartItems': cartItemsData
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: const Text('Payment has been uploaded'),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const HomePage(),
                  ),
                ),
                child: const Text('Ok'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: const Text('Payment error, please try again.'),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Exit'),
              ),
            ],
          );
        },
      );
    }
  }

  Widget _buildBankTransferWidget() {
    return Column(
      children: [
        Text(
          'Total Price: RM ${widget.totalPrice.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text('Please transfer the payment to the following account:'),
        const SizedBox(height: 10),
        const Text('Bank Name: CIMBD Bank'),
        const SizedBox(height: 5),
        const Text('Account Name: John Doe'),
        const SizedBox(height: 5),
        const Text('Account Number: 1231212412'),
        const SizedBox(height: 20),
        const Text('Upload Payment Proof'),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFA500)),
          onPressed: () async {
            File? file = await _uploadFile();
            _uploadFileFirebase(file!);
          },
          child: const Text('Upload Payment'),
        ),
      ],
    );
  }

  Widget _buildEWalletWidget() {
    String? _selectedOption;
    return Column(
      children: [
        Text(
          'Total Price: RM ${widget.totalPrice.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text('Select Payment Method'),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            midtransPayment();
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            backgroundColor: Colors.blue,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/midtrans-logo.png',
                height: 30,
                color: Colors.white,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8.0),
        ElevatedButton(
          onPressed: () {
            // Button action
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            backgroundColor: const Color.fromRGBO(255, 204, 0, 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/PaypalLogo.png',
                height: 30,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFA500)),
          onPressed: () {},
          child: const Text('Continue'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: const Color(0xFFFFA500),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.1,
          vertical: size.height * 0.05,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Payment Option'),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: _selectedPaymentOption,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentOption = value!;
                });
              },
              items: _paymentOptions
                  .map<DropdownMenuItem<String>>(
                    (String value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),
            if (_selectedPaymentOption == 'Bank Transfer')
              _buildBankTransferWidget()
            else if (_selectedPaymentOption == 'E-Wallet')
              _buildEWalletWidget()
          ],
        ),
      ),
    );
  }

  Future<File?> _uploadFile() async {
    File? selectedFile;
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      selectedFile = File(pickedFile.path);
      return selectedFile;
    } else {
      print('Image picker canceled');
    }
  }

  midtransPayment() async {
    User? user = _auth.currentUser;
    _cartItems = widget.cartItems;
    List<Map<String, dynamic>> cartItemsData = [];
    for (var cartItem in _cartItems) {
      cartItemsData.add(cartItem.toMap());
    }
    var orderId = DateTime.now().millisecondsSinceEpoch.toString();
    Map data = {
      'orderId': orderId,
      'paymentType': 'midtrans',
      'amount': widget.totalPrice,
      'uid': user?.uid,
      'deliveryDate': DateFormat.yMMMMd().format(widget.deliveryDay).toString(),
      'cartItems': cartItemsData
    };
    var body = json.encode(data);
    print('Request Body: $body');
    final response = await api.post(
        "https://77b8-113-210-87-32.ngrok-free.app/payment", body);
    if (response is Map<String, dynamic>) {
      String redirectUrl = response['redirectUrl'];
      print('URL: $redirectUrl');
      final Uri _url = Uri.parse(redirectUrl);
      if (!await launchUrl(_url)) {
        throw Exception('Could not launch $_url');
      }
    } else {
      print('Invalid response format');
    }
  }
}
