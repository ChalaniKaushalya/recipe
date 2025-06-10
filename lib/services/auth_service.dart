import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> registerUser({
  required String email,
  required String password,
  required String userName,
  required String userPhone,
  required String userAddress,
  required DateTime userBirthday,
  required String userProfilePicture,
}) async {
  try {
    // Create user with email and password
    UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Get the user ID
    String uid = userCredential.user!.uid;

    // Save user details to Firestore
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'userName': userName,
      'userPhone': userPhone,
      'userAddress': userAddress,
      'userBirthday': userBirthday.toIso8601String(),
      'userProfilePicture': userProfilePicture,
    });

    print('User registered and details saved to Firestore');
  } catch (e) {
    print('Error registering user: $e');
  }
}
