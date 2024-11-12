import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:foodservice/checkout.dart';
import 'package:foodservice/checkout2.dart';
import 'package:foodservice/l10n/l10n.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodservice/home.dart';
import 'package:foodservice/login.dart';
import 'package:foodservice/orders.dart';
import 'package:foodservice/orders2.dart';
import 'package:foodservice/services.dart';
import 'addtocart.dart';

// ignore: camel_case_types
class productPage extends StatefulWidget {
  final String pincode;

  const productPage({super.key, required this.pincode});

  @override
  // ignore: library_private_types_in_public_api
  _productPageState createState() => _productPageState();
}

// ignore: camel_case_types
class _productPageState extends State<productPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  String? selectedCategory;
  String? selectedDietary; // Added state variable for selected dietary

  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> categoryKeys = {};

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCategory(String? category) {
    if (category != null && categoryKeys.containsKey(category)) {
      final key = categoryKeys[category];
      if (key != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final context = key.currentContext;
          if (context != null) {
            Scrollable.ensureVisible(context,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut);
          }
        });
      }
    }
  }

  Locale _locale = const Locale('en'); // Default locale

  void _changeLanguage(String languageCode) {
    setState(() {
      _locale = Locale(languageCode);
    });
  }

  String logo = "";

  @override
  void initState() {
    super.initState();
    // Fetch data based on the provided UID when the widget initializes
    fetchLogo();
  }

  void fetchLogo() {
    FirebaseFirestore.instance
        .collection('logo')
        .doc('96pTtFXwWIx2UCtbeDoL')
        .snapshots()
        .listen((DocumentSnapshot querySnapshot) {
      if (querySnapshot.exists) {
        var userData = querySnapshot.data() as Map<String, dynamic>?;

        if (userData != null) {
          setState(() {
            logo = userData['image'] ?? '';

            // Update other controllers for other fields accordingly
          });
        }
      } else {
        // Handle the case where the document does not exist
        print('Document does not exist.');
      }
    }, onError: (e) {
      print('Error fetching logo: $e');
    });
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
// 2 columns on mobile, 4 on larger screens

    double prodnameSize = 0;
    if (deviceWidth <= 360) {
      prodnameSize = 15;
    } else if (deviceWidth <= 412) {
      prodnameSize = 20;
    } else if (deviceWidth <= 900) {
      prodnameSize = 25;
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      supportedLocales: L10n.all,
      locale: _locale,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        AppLocalizations.delegate,
      ],
      builder: (context, child) {
        return Directionality(
          textDirection: Localizations.localeOf(context).languageCode == 'zh' ||
                  Localizations.localeOf(context).languageCode == 'ja' ||
                  Localizations.localeOf(context).languageCode == 'id'
              ? TextDirection.ltr
              : TextDirection.ltr,
          child: child!,
        );
      },
      home: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.white,
        body: Row(
          children: [
            deviceWidth > 600
                ? SizedBox(
                    width: MediaQuery.of(context).size.width / 5,
                    child: ListView(
                      children: [
                        DrawerHeader(
                          padding: EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color: Colors.white,
                          ),
                          child: Image.network(
                            logo,
                          ),
                        ),
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('category')
                              .orderBy('id')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            final categories = snapshot.data!.docs;

                            // Map categories to a list of maps with id and data
                            List<Map<String, dynamic>> categoryList =
                                categories.map((doc) {
                              return {
                                'id': int.tryParse(doc.id) ??
                                    0, // Parse the id to an integer
                                'data': doc.data() as Map<String, dynamic>,
                              };
                            }).toList();

                            // Sort the list based on 'id' in ascending order
                            categoryList
                                .sort((a, b) => a['id'].compareTo(b['id']));

                            return Column(
                              children: categoryList.map((category) {
                                bool isSelected = selectedCategory ==
                                    category['data']['category'];
                                return ListTile(
                                  tileColor: isSelected
                                      ? Colors.blue // Active color
                                      : Colors.transparent, // Default color
                                  title:
                                      Text(' ${category['data']['category']}'),
                                  onTap: () {
                                    setState(() {
                                      selectedCategory =
                                          category['data']['category'] ?? '';
                                    });
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                      _scrollToCategory(selectedCategory);
                                    });
                                  },
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  )
                : const SizedBox(),
            Expanded(
                child: Column(
              children: [
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    height: 100,
                    child: Row(
                      children: [
                        Builder(builder: (context) {
                          final localizations = AppLocalizations.of(context)!;
                          return Text(
                            localizations.label1,
                            style: const TextStyle(fontSize: 20),
                          );
                        }),
                        Expanded(
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('dietary')
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                final List<DocumentSnapshot> data =
                                    snapshot.data!.docs;

                                return ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: data.length +
                                      1, // Increase item count by 1
                                  itemBuilder: (context, index) {
                                    if (index == data.length) {
                                      // If it's the last item, return the "Show All" button
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedDietary = 'Show All';
                                          });
                                        },
                                        child: Center(
                                          child: Builder(builder: (context) {
                                            final localizations =
                                                AppLocalizations.of(context)!;
                                            return Text(
                                              localizations.label2,
                                              style: TextStyle(
                                                fontSize: 20,
                                                decoration: selectedDietary ==
                                                        'Show All'
                                                    ? TextDecoration.underline
                                                    : TextDecoration.none,
                                              ),
                                            );
                                          }),
                                        ),
                                      );
                                    } else {
                                      // Otherwise, return the dietary item
                                      final dietary = data[index].data()
                                          as Map<String, dynamic>;
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedDietary =
                                                dietary['name'] ?? '';
                                          });
                                        },
                                        child: Center(
                                          child: Image.network(
                                            dietary['image'] ?? '',
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return const Text(
                                                  'Failed to load image');
                                            },
                                            width: 50,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                );
                              } else if (snapshot.hasError) {
                                return Center(
                                    child: Text('Error: ${snapshot.error}'));
                              } else {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                            },
                          ),
                        ),
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            alignment: Alignment.centerRight,
                            child: DropdownButton<String>(
                              value: _locale.languageCode == 'en'
                                  ? 'English'
                                  : _locale.languageCode == 'zh'
                                      ? 'Chinese'
                                      : _locale.languageCode == 'ja'
                                          ? 'Japanese'
                                          : _locale.languageCode == 'id'
                                              ? 'Indonesian'
                                              : 'en', // Default or fallback value
                              dropdownColor: Colors.white,
                              icon: const Icon(
                                Icons.language,
                                color: Colors.black,
                              ),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  _changeLanguage(
                                      newValue = newValue == 'English'
                                          ? 'en'
                                          : newValue == 'Chinese'
                                              ? 'zh'
                                              : newValue == 'Japanese'
                                                  ? 'ja'
                                                  : newValue == 'Indonesian'
                                                      ? 'id'
                                                      : 'en');
                                }
                              },
                              items: [
                                'English',
                                'Chinese',
                                'Japanese',
                                'Indonesian'
                              ].map<DropdownMenuItem<String>>(
                                  (String language) {
                                return DropdownMenuItem<String>(
                                  value: language,
                                  child: Text(language),
                                );
                              }).toList(),
                            ),
                          ),
                        )
                      ],
                    )),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('product')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final filteredProducts =
                              snapshot.data!.docs.where((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final dietary = data['dietary'] ?? '';

                            return selectedDietary == 'Show All' ||
                                dietary.toString().toLowerCase().contains(
                                    selectedDietary?.toLowerCase() ?? '');
                          }).toList();

                          final productsByCategory =
                              _groupProductsByCategory(filteredProducts);

                          return Column(
                            children:
                                productsByCategory.keys.map<Widget>((category) {
                              final products = productsByCategory[category]!;

                              categoryKeys.putIfAbsent(
                                  category, () => GlobalKey());

                              return Padding(
                                key: categoryKeys[category],
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.only(left: 20),
                                      child: Text(
                                        category,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xddc64a45),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      child: GridView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                          crossAxisSpacing: 10,
                                          mainAxisSpacing: 10,
                                          childAspectRatio: 1.48,
                                        ),
                                        padding: const EdgeInsets.all(10),
                                        itemCount: products.length,
                                        itemBuilder: (context, index) {
                                          var doc = products[index].data()
                                              as Map<String, dynamic>;

                                          final dietaryImages =
                                              (doc['dietary_image'] ?? '')
                                                  .split(',');

                                          return GestureDetector(
                                            onTap: () {
                                              showDialog(
                                                barrierDismissible: false,
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    content: SizedBox(
                                                      width: 700,
                                                      child: addtocartPage(
                                                        docId:
                                                            products[index].id,
                                                        pincode: widget.pincode,
                                                        dietary_image: doc[
                                                            'dietary_image'],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: const Color.fromARGB(
                                                      255, 218, 218, 218),
                                                  width: 2,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Stack(
                                                    children: [
                                                      Center(
                                                        child: Image.network(
                                                          doc['image'] ?? '',
                                                          width:
                                                              double.infinity,
                                                          fit: BoxFit.cover,
                                                          height: 160,
                                                        ),
                                                      ),
                                                      Positioned(
                                                        top: 10,
                                                        right: 10,
                                                        child: SizedBox(
                                                          height: 100,
                                                          child: Wrap(
                                                            alignment:
                                                                WrapAlignment
                                                                    .end,
                                                            spacing: 5,
                                                            runSpacing: 5,
                                                            children:
                                                                dietaryImages.map<
                                                                        Widget>(
                                                                    (imageUrl) {
                                                              return Image
                                                                  .network(
                                                                imageUrl,
                                                                width: 30,
                                                                height: 30,
                                                                fit: BoxFit
                                                                    .cover,
                                                              );
                                                            }).toList(),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8.0),
                                                    child: Text(
                                                      doc['name'] ?? '',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors
                                                            .grey.shade400,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Container(
                                                    alignment:
                                                        AlignmentDirectional
                                                            .bottomEnd,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8.0),
                                                    child: Text(
                                                      'Price: \$${doc['price']}',
                                                      style: const TextStyle(
                                                        color: Colors.green,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                  ],
                                ),
                              );
                            }).toList(), // Convert to List<Widget>
                          );
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      },
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  height: 60,
                  child: Builder(
                    builder: (context) {
                      final localizations = AppLocalizations.of(context)!;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                              onTap: () {
                                if (widget.pincode == '0000') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: ((context) =>
                                            const loginPage())),
                                  );
                                } else {
                                  showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        content: SizedBox(
                                          width: 700,
                                          child: ordersPage(
                                            pincode: widget.pincode,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }
                              },
                              child: Text(
                                localizations.label3,
                                style: const TextStyle(fontSize: 20),
                              )),
                          const Text(
                            '|',
                            style: TextStyle(fontSize: 20),
                          ),
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Assistance Needed'),
                                    content: const Text(
                                        'Do you want to call for assistance?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Services().callforassistance(
                                              'yes', widget.pincode);
                                        },
                                        child: const Text('Yes'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Services().callforassistance(
                                              'no', widget.pincode);
                                          Navigator.of(context)
                                              .pop(); // Close the dialog
                                        },
                                        child: const Text('No'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Text(
                              localizations.label4,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                          const Text(
                            '|',
                            style: TextStyle(fontSize: 20),
                          ),
                          GestureDetector(
                              onTap: () {
                                // if (widget.pincode == '0000') {
                                showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      content: SizedBox(
                                        width: 700,
                                        child: checkoutPage2(
                                          pincode: widget.pincode,
                                        ),
                                      ),
                                    );
                                  },
                                );
                                // } else {
                                //   showDialog(
                                //     barrierDismissible: false,
                                //     context: context,
                                //     builder: (BuildContext context) {
                                //       return AlertDialog(
                                //         content: SizedBox(
                                //           width: 700,
                                //           child: checkoutPage(
                                //             pincode: widget.pincode,
                                //           ),
                                //         ),
                                //       );
                                //     },
                                //   );
                                // }
                              },
                              child: Text(
                                localizations.label5,
                                style: const TextStyle(fontSize: 20),
                              )),
                        ],
                      );
                    },
                  ),
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Map<String, List<QueryDocumentSnapshot>> _groupProductsByCategory(
      List<QueryDocumentSnapshot> products) {
    Map<String, List<QueryDocumentSnapshot>> productsByCategory = {};

    for (var product in products) {
      var data = product.data() as Map<String, dynamic>;
      var category = data['category'] ?? 'Unknown';
      if (category != null) {
        if (!productsByCategory.containsKey(category)) {
          productsByCategory[category] = [];
        }
        productsByCategory[category]!.add(product);
      }
    }
    return productsByCategory;
  }
}
