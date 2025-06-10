import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> testFirebaseConnection() async {
  try {
    // Attempt to fetch data from Firestore
    var snapshot = await FirebaseFirestore.instance.collection('test').get();
    if (snapshot.docs.isNotEmpty) {
      print('Connected to Firebase and data is available!');
    } else {
      print('Connected to Firebase but no data found.');
    }
  } catch (e) {
    print('Error connecting to Firebase: $e');
  }
}
