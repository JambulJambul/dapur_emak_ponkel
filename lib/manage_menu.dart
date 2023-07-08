import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;
import 'cart.dart';

class OwnerManageMenu extends StatefulWidget {
  const OwnerManageMenu({Key? key}) : super(key: key);

  @override
  State<OwnerManageMenu> createState() => _OwnerManageMenuState();
}

class _OwnerManageMenuState extends State<OwnerManageMenu> {
  DateTime _focusedDay = DateTime.now().add(const Duration(days: 1));
  DateTime? _selectedDay = DateTime.now().add(const Duration(days: 1));
  DateTime? _lastDay = DateTime.now().add(const Duration(days: 2));
  TextEditingController _menuTitleController = TextEditingController();
  TextEditingController _menuDescriptionController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  bool _eventMenu = true;
  final List<bool> _eventMenuOptions = [true, false];
  String _foodType = "maincourse";
  final Map<String, String> _foodTypeOptions = {
    "maincourse": "Main Course",
    "sidedish": "Side Dish",
    "riceoption": "Rice Option",
    "multiday": "Set Package",
  };
  File? file;

  void _editMenu(BuildContext context, String docid, String downloadUrl,
      String menuTitle, String menuDescription, int price) async {
    try {
      if (_menuTitleController.text.trim().isNotEmpty) {
        menuTitle = _menuTitleController.text.trim();
      }
      if (_menuDescriptionController.text.trim().isNotEmpty) {
        menuDescription = _menuDescriptionController.text.trim();
      }
      if (_priceController.text.trim().isNotEmpty) {
        double? price = double.tryParse(_priceController.text);
      }
      if (file != null) {
        String downloadUrl = await _uploadImageFirebase(file!);
      }

      await FirebaseFirestore.instance.collection('foodmenu').doc(docid).update(
        {
          'eventmenu': _eventMenu,
          'foodtype': _foodType,
          'imageurl': downloadUrl,
          'menudesc': menuDescription,
          'menutitle': menuTitle,
          'price': price,
        },
      );
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: const Text('Menu has been uploaded'),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Exit'),
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
            content: const Text('Upload error, please try again.'),
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

  void _uploadMenu(BuildContext context) async {
    String menuTitle = _menuTitleController.text.trim();
    String menuDescription = _menuDescriptionController.text.trim();
    int? price = int.tryParse(_priceController.text);

    try {
      String downloadUrl = await _uploadImageFirebase(file!);

      await FirebaseFirestore.instance.collection('foodmenu').add(
        {
          'eventmenu': _eventMenu,
          'foodtype': _foodType,
          'imageurl': downloadUrl,
          'menudesc': menuDescription,
          'menutitle': menuTitle,
          'price': price,
        },
      );
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: const Text('Menu has been uploaded'),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Exit'),
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
            content: const Text('Upload error, please try again.'),
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

  Future<String> _uploadImageFirebase(File file) async {
    try {
      String fileName = Path.basename(file.path);
      Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('menu/image/$fileName');
      UploadTask uploadTask = ref.putFile(file);
      await uploadTask.whenComplete(() => null);
      String downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Upload error, please try again.');
    }
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
    return null;
  }

  Widget _cardBuilder(AsyncSnapshot<QuerySnapshot<Object?>> snapshot,
      String menuAssignment, String foodTypeCard) {
    final size = MediaQuery.of(context).size;
    final double buttonWidth = size.width * 0.4;
    final textFieldWidth = size.width * 0.6;
    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      return Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(
            opacity: 0.2,
            child: Image.asset(
              'assets/images/NicePng_restaurant-icon-png_2018040.png', // Replace with the path to your image
              width: 150.0,
              height: 150.0,
            ),
          ),
          const SizedBox(height: 20.0),
          const Text(
            'Menu is not available for this date',
            style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.grey),
          ),
        ],
      ));
    }
    if (snapshot.hasData) {
      final List<QueryDocumentSnapshot> documents = snapshot.data!.docs;
      List<bool> _eventMainMenuOptions =
          List<bool>.filled(documents.length, false);
      List<bool> _eventSideMenuOptions =
          List<bool>.filled(documents.length, false);
      List<bool> _eventRiceMenuOptions =
          List<bool>.filled(documents.length, false);
      List<bool> _eventPackageMenuOptions =
          List<bool>.filled(documents.length, false);
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: documents.length,
        itemBuilder: (BuildContext context, int index) {
          final doc = documents[index];
          String label = doc['menutitle'];
          String imgUrl = doc['imageurl'];
          String itemDesc = doc['menudesc'];
          var itemprice = doc['price'] as int;

          bool foodTypeBool = doc['eventmenu'] as bool;

          if (menuAssignment == 'maincourse') {
            _eventMainMenuOptions[index] = foodTypeBool;
          }
          if (menuAssignment == 'sidedish') {
            _eventSideMenuOptions[index] = foodTypeBool;
          }
          if (menuAssignment == 'riceoption') {
            _eventRiceMenuOptions[index] = foodTypeBool;
          }
          if (menuAssignment == 'multiday') {
            _eventPackageMenuOptions[index] = foodTypeBool;
          }

          return Column(
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                        fit: FlexFit.loose,
                        flex: 1,
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16.0),
                              bottomLeft: Radius.circular(16.0),
                            ),
                            child: Image.network(
                              imgUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )),
                    Flexible(
                      fit: FlexFit.loose,
                      flex: 2,
                      child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                label,
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  ElevatedButton(
                                      onPressed: () {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return Dialog(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          16.0),
                                                ),
                                                child: SingleChildScrollView(
                                                  child: IntrinsicWidth(child:
                                                      StatefulBuilder(builder:
                                                          (BuildContext context,
                                                              StateSetter
                                                                  setState) {
                                                    return Padding(
                                                      padding: const EdgeInsets
                                                              .fromLTRB(
                                                          16, 16, 16, 16),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          const Text(
                                                            "Edit Menu",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 16),
                                                          ),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          Image.network(
                                                            imgUrl,
                                                            height: 200,
                                                            fit: BoxFit.cover,
                                                          ),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          SizedBox(
                                                            width:
                                                                textFieldWidth,
                                                            child: TextField(
                                                              controller:
                                                                  _menuTitleController,
                                                              decoration:
                                                                  const InputDecoration(
                                                                labelText:
                                                                    'Menu Name',
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          SizedBox(
                                                            width:
                                                                textFieldWidth,
                                                            child: TextField(
                                                              controller:
                                                                  _menuDescriptionController,
                                                              decoration:
                                                                  const InputDecoration(
                                                                labelText:
                                                                    'Menu Description',
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          SizedBox(
                                                              width:
                                                                  textFieldWidth,
                                                              child: TextField(
                                                                  controller:
                                                                      _priceController,
                                                                  decoration:
                                                                      const InputDecoration(
                                                                    labelText:
                                                                        'Price',
                                                                  ))),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          const Text(
                                                              "Is the menu available for events?"),
                                                          DropdownButton<bool>(
                                                            value: _eventMenu,
                                                            onChanged: (value) {
                                                              setState(() {
                                                                _eventMenu =
                                                                    value!;
                                                              });
                                                            },
                                                            items:
                                                                _eventMenuOptions
                                                                    .map<
                                                                        DropdownMenuItem<
                                                                            bool>>(
                                                                      (bool value) =>
                                                                          DropdownMenuItem<
                                                                              bool>(
                                                                        value:
                                                                            value,
                                                                        child: Text(value
                                                                            ? 'Yes'
                                                                            : 'No'),
                                                                      ),
                                                                    )
                                                                    .toList(),
                                                          ),
                                                          const Text(
                                                              "Select food category"),
                                                          DropdownButton<
                                                              String>(
                                                            value: _foodType,
                                                            onChanged: (value) {
                                                              setState(() {
                                                                _foodType =
                                                                    value!;
                                                              });
                                                            },
                                                            items: _foodTypeOptions
                                                                .keys
                                                                .map<
                                                                    DropdownMenuItem<
                                                                        String>>(
                                                                  (String value) =>
                                                                      DropdownMenuItem<
                                                                          String>(
                                                                    value:
                                                                        value,
                                                                    child: Text(
                                                                        _foodTypeOptions[
                                                                            value]!),
                                                                  ),
                                                                )
                                                                .toList(),
                                                          ),
                                                          ElevatedButton(
                                                            style: ElevatedButton.styleFrom(
                                                                backgroundColor:
                                                                    const Color(
                                                                        0xFFFFA500)),
                                                            onPressed:
                                                                () async {
                                                              file =
                                                                  (await _uploadFile())!;
                                                              setState(() {});
                                                            },
                                                            child: const Text(
                                                                'Upload Food Image'),
                                                          ),
                                                          if (file != null) ...[
                                                            const SizedBox(
                                                              height: 10,
                                                            ),
                                                            const Text(
                                                                "Image has been uploaded")
                                                          ],
                                                          Align(
                                                            alignment: Alignment
                                                                .center,
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                ElevatedButton(
                                                                  onPressed:
                                                                      () async {
                                                                    if (_priceController
                                                                        .text
                                                                        .isNotEmpty) {
                                                                      if (!RegExp(
                                                                              r'^\d+$')
                                                                          .hasMatch(
                                                                              _priceController.text)) {
                                                                        showDialog(
                                                                          context:
                                                                              context,
                                                                          builder:
                                                                              (BuildContext context) {
                                                                            return Dialog(
                                                                              shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(16.0),
                                                                              ),
                                                                              child: const IntrinsicWidth(
                                                                                  child: Padding(
                                                                                padding: EdgeInsets.all(16),
                                                                                child: Text("Please insert correct price"),
                                                                              )),
                                                                            );
                                                                          },
                                                                        );
                                                                      }
                                                                    } else {
                                                                      String
                                                                          menuTitle =
                                                                          label;
                                                                      String
                                                                          menuDescription =
                                                                          itemDesc;
                                                                      int price =
                                                                          itemprice;
                                                                      String
                                                                          downloadUrl =
                                                                          imgUrl;
                                                                      _editMenu(
                                                                          context,
                                                                          doc.id,
                                                                          downloadUrl,
                                                                          menuTitle,
                                                                          menuDescription,
                                                                          price);
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    }
                                                                  },
                                                                  style:
                                                                      ButtonStyle(
                                                                    backgroundColor: MaterialStateProperty.all<
                                                                            Color>(
                                                                        Colors
                                                                            .orange),
                                                                  ),
                                                                  child: const Text(
                                                                      "Submit"),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  })),
                                                ),
                                              );
                                            });
                                      },
                                      child: const Text("Edit Menu"),
                                      style: ButtonStyle(
                                          side: const MaterialStatePropertyAll(
                                              BorderSide(
                                            color: Colors.orange,
                                            width: 1.5,
                                            strokeAlign: 1,
                                          )),
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Colors.orange))),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  SizedBox(
                                    width: 20,
                                    child: TextButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return Dialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16.0),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(16.0),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Image.network(
                                                      imgUrl,
                                                      height: 200,
                                                      width: double.infinity,
                                                      fit: BoxFit.cover,
                                                    ),
                                                    const SizedBox(height: 16),
                                                    Text(
                                                      label,
                                                      style: const TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      itemDesc,
                                                      style: const TextStyle(
                                                          fontSize: 16),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      "Price: Rp$itemprice",
                                                      style: const TextStyle(
                                                          fontSize: 16),
                                                    ),
                                                    const SizedBox(height: 16),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child:
                                                          const Text('Close'),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      child: const SizedBox(
                                        width: 10,
                                        child: Icon(
                                          Icons.info,
                                          color: Colors.orange,
                                        ),
                                      ),
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  SizedBox(
                                    width: 20,
                                    child: TextButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return Dialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16.0),
                                              ),
                                              child: IntrinsicWidth(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          16, 16, 16, 16),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      const Text(
                                                        "Are you sure to delete the menu?",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 16),
                                                      ),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      Align(
                                                        alignment:
                                                            Alignment.center,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            ElevatedButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              style:
                                                                  ButtonStyle(
                                                                backgroundColor:
                                                                    MaterialStateProperty.all<
                                                                            Color>(
                                                                        Colors
                                                                            .orange),
                                                              ),
                                                              child: const Text(
                                                                  "No"),
                                                            ),
                                                            const SizedBox(
                                                                width: 10),
                                                            ElevatedButton(
                                                              onPressed: () {
                                                                FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        'foodmenu')
                                                                    .doc(doc.id)
                                                                    .delete();
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              style:
                                                                  ButtonStyle(
                                                                backgroundColor:
                                                                    MaterialStateProperty.all<
                                                                            Color>(
                                                                        Colors
                                                                            .red),
                                                              ),
                                                              child: const Text(
                                                                  "Yes"),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      child: const SizedBox(
                                        width: 10,
                                        child: Icon(
                                          Icons.delete,
                                          color: Colors.orange,
                                        ),
                                      ),
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          )),
                    ),
                  ],
                ),
              )
            ],
          );
        },
      );
    }
    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    }
    return const CircularProgressIndicator();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double buttonWidth = size.width * 0.4;
    final textFieldWidth = size.width * 0.6;

    return Scaffold(
        appBar: AppBar(
          title: const Text('Manage Menu'),
          backgroundColor: const Color(0xFFFFA500),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.1,
              vertical: size.height * 0.05,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  children: [
                    FloatingActionButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                child: SingleChildScrollView(
                                  child: IntrinsicWidth(child: StatefulBuilder(
                                      builder: (BuildContext context,
                                          StateSetter setState) {
                                    return Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          16, 16, 16, 16),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text(
                                            "New Menu",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          SizedBox(
                                            width: textFieldWidth,
                                            child: TextField(
                                              controller: _menuTitleController,
                                              decoration: const InputDecoration(
                                                labelText: 'Menu Name',
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          SizedBox(
                                            width: textFieldWidth,
                                            child: TextField(
                                              controller:
                                                  _menuDescriptionController,
                                              decoration: const InputDecoration(
                                                labelText: 'Menu Description',
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          SizedBox(
                                              width: textFieldWidth,
                                              child: TextField(
                                                  controller: _priceController,
                                                  decoration:
                                                      const InputDecoration(
                                                    labelText: 'Price',
                                                  ))),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          const Text(
                                              "Is the menu available for events?"),
                                          DropdownButton<bool>(
                                            value: _eventMenu,
                                            onChanged: (value) {
                                              setState(() {
                                                _eventMenu = value!;
                                              });
                                            },
                                            items: _eventMenuOptions
                                                .map<DropdownMenuItem<bool>>(
                                                  (bool value) =>
                                                      DropdownMenuItem<bool>(
                                                    value: value,
                                                    child: Text(
                                                        value ? 'Yes' : 'No'),
                                                  ),
                                                )
                                                .toList(),
                                          ),
                                          const Text("Select food category"),
                                          DropdownButton<String>(
                                            value: _foodType,
                                            onChanged: (value) {
                                              setState(() {
                                                _foodType = value!;
                                              });
                                            },
                                            items: _foodTypeOptions.keys
                                                .map<DropdownMenuItem<String>>(
                                                  (String value) =>
                                                      DropdownMenuItem<String>(
                                                    value: value,
                                                    child: Text(
                                                        _foodTypeOptions[
                                                            value]!),
                                                  ),
                                                )
                                                .toList(),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    const Color(0xFFFFA500)),
                                            onPressed: () async {
                                              file = (await _uploadFile())!;
                                              setState(() {});
                                            },
                                            child:
                                                const Text('Upload Food Image'),
                                          ),
                                          if (file != null) ...[
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            const Text(
                                                "Image has been uploaded")
                                          ],
                                          Align(
                                            alignment: Alignment.center,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    if (_menuTitleController
                                                            .text.isEmpty ||
                                                        _menuDescriptionController
                                                            .text.isEmpty ||
                                                        _priceController
                                                            .text.isEmpty ||
                                                        file == null ||
                                                        !RegExp(r'^\d+$')
                                                            .hasMatch(
                                                                _priceController
                                                                    .text)) {
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return Dialog(
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          16.0),
                                                            ),
                                                            child:
                                                                const IntrinsicWidth(
                                                                    child:
                                                                        Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(16),
                                                              child: Text(
                                                                  "Please fill all the information and input a valid number for the price"),
                                                            )),
                                                          );
                                                        },
                                                      );
                                                    } else {
                                                      _uploadMenu(context);
                                                      Navigator.of(context)
                                                          .pop();
                                                    }
                                                  },
                                                  style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all<Color>(
                                                                Colors.orange),
                                                  ),
                                                  child: const Text("Submit"),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  })),
                                ),
                              );
                            });
                      },
                      child: const Icon(Icons.add),
                      backgroundColor: Colors.orange,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      'Add New Menu',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('foodmenu')
                        .where('foodtype', isEqualTo: "maincourse")
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      String _foodType = 'maincourse';
                      return Column(
                        children: [
                          const Row(
                            children: [
                              Text(
                                "Main Course",
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 22),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          _cardBuilder(snapshot, 'maincourse', _foodType),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      );
                    }),
                StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('foodmenu')
                        .where('foodtype', isEqualTo: "sidedish")
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      String _foodType = 'sidedish';
                      return Column(
                        children: [
                          const Row(
                            children: [
                              Text(
                                "Side Dish",
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 22),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          _cardBuilder(snapshot, 'sidedish', _foodType),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      );
                    }),
                StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('foodmenu')
                        .where('foodtype', isEqualTo: "riceoption")
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      String _foodType = 'riceoption';
                      return Column(
                        children: [
                          const Row(
                            children: [
                              Text(
                                "Rice Option",
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 22),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          _cardBuilder(snapshot, 'riceoption', _foodType),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      );
                    }),
                StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('foodmenu')
                        .where('foodtype', isEqualTo: "multiday")
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      String _foodType = 'multiday';
                      return Column(
                        children: [
                          const Row(
                            children: [
                              Text(
                                "Event Package",
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 22),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          _cardBuilder(snapshot, 'multiday', _foodType),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      );
                    }),
              ],
            ),
          ),
        ));
  }
}
