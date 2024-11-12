import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:foodservice/product.dart';
import 'package:foodservice/services.dart';

// ignore: camel_case_types
class addtocartPage extends StatefulWidget {
  final String docId;
  // ignore: prefer_typing_uninitialized_variables
  final pincode;
  // ignore: non_constant_identifier_names
  final String dietary_image;
  const addtocartPage(
      {super.key,
      required this.docId,
      required this.pincode,
      // ignore: non_constant_identifier_names
      required this.dietary_image});

  @override
  // ignore: library_private_types_in_public_api
  _addtocartPageState createState() => _addtocartPageState();
}

// ignore: camel_case_types
class _addtocartPageState extends State<addtocartPage> {
  TextEditingController quantityController = TextEditingController();
  int quantity = 1;
  int productquantity = 1;
  final TextEditingController _addonsController = TextEditingController();
  final TextEditingController _addonspriceController = TextEditingController();
  Map<String, Map<String, dynamic>> selectedAddons =
      {}; // Map to store add-ons with their details
  double totalAddons = 0.0;

  void _increaseQuantity() {
    setState(() {
      productquantity++;
    });
  }

  void _decreaseQuantity() {
    setState(() {
      if (productquantity > 0) {
        productquantity--;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    quantityController.text = quantity.toString();
  }

  void incrementQuantity() {
    setState(() {
      quantity++;
      quantityController.text = quantity.toString();
    });
  }

  void decrementQuantity() {
    if (quantity > 1) {
      setState(() {
        quantity--;
        quantityController.text = quantity.toString();
      });
    }
  }

  void addToTextField(String addonId, String addonName, String addonPrice) {
    setState(() {
      if (selectedAddons.containsKey(addonId)) {
        selectedAddons[addonId]!['quantity']++;
      } else {
        selectedAddons[addonId] = {
          'name': addonName,
          'price': addonPrice,
          'quantity': 1,
        };
      }
      _updateAddonsController();
      totalAddons += double.parse(addonPrice);
    });
  }

  void removeAddOn(String addonId) {
    setState(() {
      if (selectedAddons.containsKey(addonId)) {
        if (selectedAddons[addonId]!['quantity'] > 1) {
          selectedAddons[addonId]!['quantity']--;
          totalAddons -= double.parse(selectedAddons[addonId]!['price']);
        } else {
          totalAddons -= double.parse(selectedAddons[addonId]!['price']);
          selectedAddons.remove(addonId);
        }
        _updateAddonsController();
      }
    });
  }

  void _updateAddonsController() {
    List<String> addonsList = [];
    List<String> addonsListPrice = [];
    selectedAddons.entries.forEach((entry) {
      var details = entry.value;

      int price = int.tryParse(details['price'].toString()) ?? 0;
      int quantity = int.tryParse(details['quantity'].toString()) ?? 0;

      double total = price * quantity.toDouble();

      addonsList.add(
          '${quantity}x ${details['name']}: \$${total.toStringAsFixed(0)}');
      addonsListPrice.add('${total.toInt()},');
    });

    _addonsController.text = addonsList.join('\n');
    _addonspriceController.text = addonsListPrice.join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final dietaryImages = (widget.dietary_image).split(',');

    return Scaffold(
      body: ListView(
        children: [
          Column(
            children: [
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('product')
                    .doc(widget.docId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    var doc = snapshot.data!;

                    String nameController = doc['name'];
                    String priceController = doc['price'];
                    String imageController = doc['image'];
                    String descriptionController = doc['description'];

                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Stack(
                                children: [
                                  Center(
                                    child: Image.network(
                                      doc['image'] ?? '',
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: SizedBox(
                                      height:
                                          100, // Adjust the height as needed
                                      child: Wrap(
                                        alignment: WrapAlignment.end,
                                        spacing: 5,
                                        runSpacing: 5,
                                        children: dietaryImages
                                            .map<Widget>((imageUrl) {
                                          if (imageUrl == "") {
                                            return SizedBox();
                                          } else {
                                            return Image.network(
                                              imageUrl,
                                              width: 30,
                                              height: 30,
                                              fit: BoxFit.cover,
                                            );
                                          }
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                                child: Container(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    alignment: Alignment.bottomLeft,
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 5),
                                    child: Text(
                                      doc['name'],
                                      style: const TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    alignment: Alignment.bottomLeft,
                                    child: Text(
                                      doc['description'],
                                      style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    alignment: Alignment.bottomRight,
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 5),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          "Price: \$ ${doc['price']}",
                                          style: const TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 25),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          width: double.infinity,
                          child: const Text(
                            'Add-ons',
                            style: TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 22),
                          ),
                        ),
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('addons')
                              .where('productdocID', isEqualTo: widget.docId)
                              .snapshots(),
                          builder: (context, addonsSnapshot) {
                            if (addonsSnapshot.hasData &&
                                addonsSnapshot.data != null &&
                                addonsSnapshot.data!.docs.isNotEmpty) {
                              return Wrap(
                                spacing: 10.0, // spacing between items
                                runSpacing: 10.0, // spacing between lines
                                children:
                                    addonsSnapshot.data!.docs.map((addonDoc) {
                                  String addonId = addonDoc.id;
                                  String addonName = addonDoc['name'];
                                  String addonPrice =
                                      addonDoc['price'].toString();
                                  double.parse(addonPrice);

                                  return GestureDetector(
                                    onTap: () {
                                      addToTextField(
                                          addonId, addonName, addonPrice);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(5),
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 5),
                                      decoration: BoxDecoration(
                                        color: const Color(0xddc64a45),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize
                                            .min, // Ensures it doesn't take full width
                                        children: [
                                          Text(
                                            '$addonName: \$ $addonPrice',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12),
                                          ),
                                          const SizedBox(width: 10),
                                          GestureDetector(
                                            onTap: () {
                                              removeAddOn(addonId);
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(5),
                                              decoration: BoxDecoration(
                                                color: Colors.red,
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              child: const Text(
                                                'Remove',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              );
                            } else {
                              return const Text('No addons available');
                            }
                          },
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                                child: SizedBox(
                              height: 60,
                              child: TextField(
                                controller: _addonsController,
                                readOnly: true,
                                maxLines: null,
                                decoration: const InputDecoration(
                                  labelText: 'Selected Addons',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            )),
                            Visibility(
                                visible: false,
                                child: SizedBox(
                                  child: TextField(
                                    controller: _addonspriceController,
                                    readOnly: true,
                                    maxLines: null,
                                    decoration: const InputDecoration(
                                      labelText: 'Addons PRice',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                )),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      const Text(
                                        'QTY: ',
                                        style: TextStyle(fontSize: 25),
                                      ),
                                      Container(
                                        alignment: Alignment.bottomCenter,
                                        padding: const EdgeInsets.all(10),
                                        width: 40,
                                        decoration: BoxDecoration(
                                            color: productquantity > 1
                                                ? const Color(0xddc64a45)
                                                : Colors
                                                    .grey, // Grey out if disabled
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        child: GestureDetector(
                                            onTap: () {
                                              productquantity > 1
                                                  ? _decreaseQuantity()
                                                  : null; // Disable onTap if quantity is 1
                                            },
                                            child: const FaIcon(
                                                FontAwesomeIcons.minus)),
                                      ),
                                      Container(
                                          alignment: Alignment.bottomCenter,
                                          padding: const EdgeInsets.all(10),
                                          width: 40,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: Text(
                                            '$productquantity',
                                            style:
                                                const TextStyle(fontSize: 30),
                                          )),
                                      Container(
                                        alignment: Alignment.bottomCenter,
                                        padding: const EdgeInsets.all(10),
                                        width: 40,
                                        decoration: BoxDecoration(
                                            color: const Color(0xddc64a45),
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        child: GestureDetector(
                                            onTap: () {
                                              _increaseQuantity();
                                            },
                                            child: const FaIcon(
                                                FontAwesomeIcons.plus)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                alignment: Alignment.bottomCenter,
                                padding: const EdgeInsets.all(6),
                                width: 200,
                                decoration: BoxDecoration(
                                    color: const Color(0xddc64a45),
                                    borderRadius: BorderRadius.circular(5)),
                                child: GestureDetector(
                                  child: const Text(
                                    "Return To Menu",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17),
                                  ),
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              const Text(
                                '|',
                                style: TextStyle(fontSize: 30),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Container(
                                alignment: Alignment.bottomCenter,
                                padding: const EdgeInsets.all(6),
                                width: 200,
                                decoration: BoxDecoration(
                                    color: const Color(0xddc64a45),
                                    borderRadius: BorderRadius.circular(5)),
                                child: GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title:
                                              const Text('Order Confirmation'),
                                          content: const Text(
                                              'Are You Sure You want to Order this Product?'),
                                          actions: [
                                            GestureDetector(
                                              child: Container(
                                                alignment:
                                                    Alignment.bottomCenter,
                                                padding:
                                                    const EdgeInsets.all(10),
                                                width: 150,
                                                decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xddc64a45),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5)),
                                                child: const Text('Confirm'),
                                              ),
                                              onTap: () {
                                                Services()
                                                    .addtocart(
                                                        nameController,
                                                        priceController,
                                                        productquantity
                                                            .toString(),
                                                        imageController,
                                                        widget.docId,
                                                        widget.pincode,
                                                        descriptionController,
                                                        _addonsController.text,
                                                        _addonspriceController
                                                            .text,
                                                        totalAddons.toString())
                                                    .then((value) {
                                                  // Show the SnackBar
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      backgroundColor:
                                                          Colors.green,
                                                      content: Text(
                                                          'Successfully Added to Cart'),
                                                    ),
                                                  );

                                                  // Wait for 2 seconds before navigating
                                                  Future.delayed(
                                                      const Duration(
                                                          seconds: 2), () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                productPage(
                                                                    pincode: widget
                                                                        .pincode)));
                                                  });
                                                });
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: const Text(
                                    'Add To Order',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
