import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(historyPage());
}

// ignore: camel_case_types, use_key_in_widget_constructors
class historyPage extends StatelessWidget {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.redAccent,
          title: Row(
            children: [
              GestureDetector(
                child: const Icon(
                  Icons.arrow_left,
                  size: 40,
                ),
                onTap: () {
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (context) => productPage(),
                  //     ));
                },
              ),
              const Text('History'),
            ],
          ),
        ),
        body: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: ListView(
              children: [
                Container(
                    margin: const EdgeInsets.only(top: 20),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('orderinfo')
                          .where('uid', isEqualTo: user!.uid)
                          .snapshots(),
                      builder: ((context, snapshot) {
                        if (snapshot.hasData) {
                          final data2 = snapshot.data?.docs ?? [];

                          return Column(
                            children: data2.map((doc2) {
                              String paymentMethod = doc2['paymentmethod'];

                              return Container(
                                  alignment: Alignment.center,
                                  margin: const EdgeInsets.all(5),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey.shade400,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Column(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 5),
                                            child: Row(
                                              children: [
                                                Text(
                                                  '# ${doc2['ordernumber'].toString()}',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 20),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 5),
                                            child: Row(
                                              children: [
                                                const Text(
                                                  'Payment Method: ',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(doc2['paymentmethod'] ??
                                                    ''),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 5),
                                            child: Row(
                                              children: [
                                                const Text(
                                                  'Status: ',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(doc2['status'].toString()),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 5),
                                            child: Row(
                                              children: [
                                                const Text(
                                                  'Total: ',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(doc2['total'].toString()),
                                              ],
                                            ),
                                          ),
                                          TextButton(
                                            style: const ButtonStyle(
                                                backgroundColor:
                                                    WidgetStatePropertyAll(
                                                        Colors.orange)),
                                            onPressed: () {},
                                            child: const Row(
                                              children: [
                                                Text(
                                                  'View',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ).visible(paymentMethod == 'Gcash'),
                                        ],
                                      )
                                    ],
                                  ));
                            }).toList(),
                          );
                        } else {
                          return const Text('NO DATA');
                        }
                      }),
                    )),
              ],
            )),
      ),
    );
  }
}

extension WidgetVisibilityExtension on Widget {
  /// Conditionally shows or hides the widget based on the provided condition.
  Widget visible(bool condition) {
    return Visibility(
      visible: condition,
      child: this,
    );
  }
}
