import 'package:flutter/material.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({Key? key}) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String _selectedPaymentOption = 'Bank Transfer';

  final List<String> _paymentOptions = [
    'Bank Transfer',
    'E-Wallet',
  ];

  Widget _buildBankTransferWidget() {
    return Column(
      children: [
        const Text('Please transfer the payment to the following account:'),
        const SizedBox(height: 10),
        const Text('Bank Name: CIMBD Bank'),
        const SizedBox(height: 5),
        const Text('Account Name: John Doe'),
        const SizedBox(height: 5),
        const Text('Account Number: 1231212412'),
        const SizedBox(height: 20),
        const Text('Upload Payment Proof'),
        const SizedBox(height: 10),
        Container(
          width: 150,
          height: 150,
          color: Colors.grey[200],
          child: const Icon(Icons.upload_file),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFA500)),
          onPressed: () {},
          child: const Text('Submit'),
        ),
      ],
    );
  }

  Widget _buildEWalletWidget() {
    String? _selectedOption;
    return Column(
      children: [
        const Text('Select Payment Method'),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: RadioListTile(
                value: 'Option 1',
                groupValue: _selectedOption,
                onChanged: (value) {
                  setState(() {
                    _selectedOption = value as String?;
                  });
                },
                title: Image.asset(
                    'assets/images/toppng.com-gopay-logo-png-image-200x200.png',
                    height: 30),
                activeColor: Colors.orange,
                toggleable: true,
                selected: _selectedOption == 'Option 1',
                controlAffinity: ListTileControlAffinity.platform,
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: RadioListTile(
                value: 'Option 2',
                groupValue: _selectedOption,
                onChanged: (value) {
                  setState(() {
                    _selectedOption = value as String?;
                  });
                },
                title: Image.asset('assets/images/PaypalLogo.png', height: 30),
                activeColor: Colors.orange,
                toggleable: true,
                selected: _selectedOption == 'Option 2',
                controlAffinity: ListTileControlAffinity.platform,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFA500)),
          onPressed: () {},
          child: const Text('Submit'),
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
}
