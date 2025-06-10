import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserStore extends ChangeNotifier {
  String? address;
  DateTime? birthday;
  String? createdAt;
  String? email;
  String? fullName;
  String? phone;
  String? profilePicture;
  String? language;
  bool isLoggedIn = false;

  // Load user data from SharedPreferences
  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();

    address = prefs.getString('address');

    // Parse the birthday string into DateTime object
    String? birthdayString = prefs.getString('birthday');
    birthday = birthdayString != null
        ? DateTime.tryParse(birthdayString)
        : null;

    createdAt = prefs.getString('createdAt');
    email = prefs.getString('email');
    fullName = prefs.getString('fullName');
    phone = prefs.getString('phone');
    profilePicture = prefs.getString('profilePicture');

    isLoggedIn = email != null; // Consider user logged in if email exists
    notifyListeners();
  }

  // Save user details individually
  Future<void> login({
    required String address,
    required DateTime birthday, // Change birthday type to DateTime
    required String createdAt,
    required String email,
    required String fullName,
    required String phone,
    required String profilePicture,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    this.address = address;
    this.birthday = birthday; // Store DateTime as DateTime
    this.createdAt = createdAt;
    this.email = email;
    this.fullName = fullName;
    this.phone = phone;
    this.profilePicture = profilePicture;
    isLoggedIn = true;

    // Save birthday as a String (ISO8601 format)
    await prefs.setString('address', address);
    await prefs.setString(
      'birthday',
      birthday.toIso8601String(),
    ); // Convert DateTime to String
    await prefs.setString('createdAt', createdAt);
    await prefs.setString('email', email);
    await prefs.setString('fullName', fullName);
    await prefs.setString('phone', phone);
    await prefs.setString('profilePicture', profilePicture);

    notifyListeners();
  }

  // Logout and clear stored data
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('address');
    await prefs.remove('birthday');
    await prefs.remove('createdAt');
    await prefs.remove('email');
    await prefs.remove('fullName');
    await prefs.remove('phone');
    await prefs.remove('profilePicture');

    address = null;
    birthday = null;
    createdAt = null;
    email = null;
    fullName = null;
    phone = null;
    profilePicture = null;
    isLoggedIn = false;

    notifyListeners();
  }
}
