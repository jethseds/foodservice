import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';

class Services {
  addtocart(
      String name,
      String price,
      String quantity,
      String image,
      String docId,
      String pincode,
      String description,
      String addons,
      String addonsPrice,
      String totalAddons) async {
    if (pincode == '0000') {
      String? deviceId;

      final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

      try {
        if (Platform.isAndroid) {
          AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
          deviceId = androidInfo.id; // Unique ID on Android
        } else if (Platform.isIOS) {
          IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
          deviceId = iosInfo.identifierForVendor; // Unique ID on iOS
        }
        // ignore: empty_catches
      } catch (e) {}

      var docSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('productId', isEqualTo: docId)
          .where('pincode', isEqualTo: deviceId)
          .where('status', isEqualTo: 5)
          .get();

      if (docSnapshot.size > 0) {
        var document = docSnapshot.docs[0];
        await document.reference.update({
          'name': name,
          'price': price,
          'quantity': quantity,
          'image': image,
          'status': 5,
          'productId': docId,
          'pincode': deviceId,
          'roomnumber': deviceId,
          'description': description,
          'addons': addons,
          'addonsprice': addonsPrice,
          'addonstotal': totalAddons
        });
      } else {
        // Document doesn't exist, proceed with adding a new document
        await FirebaseFirestore.instance.collection('orders').add({
          'name': name,
          'price': price,
          'quantity': quantity,
          'image': image,
          'status': 5,
          'productId': docId,
          'pincode': deviceId,
          'roomnumber': deviceId,
          'description': description,
          'addons': addons,
          'addonsprice': addonsPrice,
          'addonstotal': totalAddons
        });
      }
    } else {
      String? deviceId;

      final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

      try {
        if (Platform.isAndroid) {
          AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
          deviceId = androidInfo.id; // Unique ID on Android
        } else if (Platform.isIOS) {
          IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
          deviceId = iosInfo.identifierForVendor; // Unique ID on iOS
        }
        // ignore: empty_catches
      } catch (e) {}
      var docSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('productId', isEqualTo: docId)
          .where('pincode', isEqualTo: pincode)
          .where('status', isEqualTo: 5)
          .get();

      if (docSnapshot.size > 0) {
        var document = docSnapshot.docs[0];
        await document.reference.update({
          'name': name,
          'price': price,
          'quantity': quantity,
          'image': image,
          'status': 5,
          'productId': docId,
          'pincode': deviceId,
          'roomnumber': deviceId,
          'description': description,
          'addons': addons,
          'addonsprice': addonsPrice,
          'addonstotal': totalAddons
        });
      } else {
        // Document doesn't exist, proceed with adding a new document
        await FirebaseFirestore.instance.collection('orders').add({
          'name': name,
          'price': price,
          'quantity': quantity,
          'image': image,
          'status': 5,
          'productId': docId,
          'pincode': deviceId,
          'roomnumber': deviceId,
          'description': description,
          'addons': addons,
          'addonsprice': addonsPrice,
          'addonstotal': totalAddons
        });
      }
    }
  }

  checkout(String pincode, String location) async {
    try {
      // Query to find all documents matching the pincode and status 0
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('pincode', isEqualTo: pincode)
          .where('status', isEqualTo: 0)
          .get();

      if (querySnapshot.size > 0) {
        // Iterate through each document and update its status
        for (var document in querySnapshot.docs) {
          await document.reference.update({
            'status': 1,
            'location': location,
          });
        }
      } else {}
      // ignore: empty_catches
    } catch (e) {}
  }

  removeproduct(String docid) async {
    try {
      // Query to find all documents matching the pincode and status 0
      await FirebaseFirestore.instance.collection('orders').doc(docid).delete();
      // ignore: empty_catches
    } catch (e) {}
  }

  checkoutincreasequantity(String docid) async {
    try {
      // Retrieve the document using the provided docid
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .doc(docid)
          .get();

      if (documentSnapshot.exists) {
        // Get the current quantity value from the document and convert it to an int
        int currentQuantity =
            int.parse(documentSnapshot['quantity'].toString());

        // Increment the quantity by 1
        int updatedQuantity = currentQuantity + 1;

        // Convert the updated quantity back to a string
        String updatedQuantityString = updatedQuantity.toString();

        // Update the document with the new quantity as a string
        await documentSnapshot.reference.update({
          'quantity': updatedQuantityString,
        });
      } else {}
      // ignore: empty_catches
    } catch (e) {}
  }

  checkoutdecreasequantity(String docid) async {
    try {
      // Retrieve the document using the provided docid
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .doc(docid)
          .get();

      if (documentSnapshot.exists) {
        // Get the current quantity value from the document and convert it to an int
        int currentQuantity =
            int.parse(documentSnapshot['quantity'].toString());

        // Increment the quantity by 1
        int updatedQuantity = currentQuantity - 1;

        // Convert the updated quantity back to a string
        String updatedQuantityString = updatedQuantity.toString();

        // Update the document with the new quantity as a string
        await documentSnapshot.reference.update({
          'quantity': updatedQuantityString,
        });
      } else {}
      // ignore: empty_catches
    } catch (e) {}
  }

  callforassistance(String callforassistance, String pincode) async {
    var docSnapshot = await FirebaseFirestore.instance
        .collection('customers')
        .where('pincode', isEqualTo: pincode)
        .get();

    if (docSnapshot.size > 0) {
      var document = docSnapshot.docs[0];
      await document.reference.update({
        'callforassistance': callforassistance,
      });
    }
  }
}
