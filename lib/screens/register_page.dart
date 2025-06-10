import 'dart:convert'; // For base64Encode
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:image_picker/image_picker.dart'; // For picking images
import 'dart:io'; // For File handling
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data'; // For web image handling

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  DateTime? _selectedDate;
  File? _selectedImage;
  Uint8List? _webImage;

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      if (kIsWeb) {
        final webImage = await image.readAsBytes();
        setState(() {
          _webImage = webImage;
        });
      } else {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    }
  }

  Future<String?> _uploadProfilePicture(File? image) async {
    if (image == null) return null;

    try {
      String fileName =
          'profile_pictures/${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = _storage.ref().child(fileName);
      UploadTask uploadTask = ref.putFile(image);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading profile picture: $e');
      return null;
    }
  }

  Future<void> _registerUser({
    required String email,
    required String password,
    required String userName,
    required String userPhone,
    required String userAddress,
    required DateTime userBirthday,
    String? userProfilePictureUrl,
    Uint8List? webImage,
  }) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      String? profilePictureBase64;
      if (kIsWeb && webImage != null) {
        profilePictureBase64 =
            'data:image/jpeg;base64,${base64Encode(webImage)}';
      }

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'fullName': userName,
        'email': email,
        'phone': userPhone,
        'address': userAddress,
        'birthday': userBirthday.toIso8601String(),
        'profilePicture': userProfilePictureUrl ?? profilePictureBase64 ?? '',
        'createdAt': DateTime.now().toIso8601String(),
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('User registered successfully!')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  bool _isPasswordStrong(String password) {
    return password.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password) &&
        RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/food_background1.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Register',
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _selectedImage != null
                            ? FileImage(_selectedImage!)
                            : _webImage != null
                            ? MemoryImage(_webImage!)
                            : null,
                        child: _selectedImage == null && _webImage == null
                            ? Icon(
                                Icons.camera_alt,
                                size: 30,
                                color: Colors.grey[700],
                              )
                            : null,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Upload Profile Picture',
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 20),
                    _buildInputField(
                      _fullNameController,
                      'Full Name',
                      Icons.person,
                    ),
                    SizedBox(height: 20),
                    _buildInputField(
                      _emailController,
                      'Email Address',
                      Icons.email,
                      isEmail: true,
                    ),
                    SizedBox(height: 20),
                    _buildInputField(
                      _phoneController,
                      'Phone Number',
                      Icons.phone,
                      isPhone: true,
                    ),
                    SizedBox(height: 20),
                    _buildInputField(
                      _addressController,
                      'Address',
                      Icons.location_on,
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => _pickDate(context),
                      child: AbsorbPointer(
                        child: _buildInputField(
                          TextEditingController(
                            text: _selectedDate != null
                                ? DateFormat(
                                    'yyyy-MM-dd',
                                  ).format(_selectedDate!)
                                : '',
                          ),
                          'Birthday',
                          Icons.calendar_today,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    _buildPasswordField(
                      _passwordController,
                      'Password',
                      _isPasswordVisible,
                      () => setState(
                        () => _isPasswordVisible = !_isPasswordVisible,
                      ),
                    ),
                    SizedBox(height: 20),
                    _buildPasswordField(
                      _confirmPasswordController,
                      'Confirm Password',
                      _isConfirmPasswordVisible,
                      () => setState(
                        () => _isConfirmPasswordVisible =
                            !_isConfirmPasswordVisible,
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          if (_passwordController.text ==
                              _confirmPasswordController.text) {
                            if (_isPasswordStrong(_passwordController.text)) {
                              String? uploadedPictureUrl =
                                  await _uploadProfilePicture(_selectedImage);
                              await _registerUser(
                                email: _emailController.text,
                                password: _passwordController.text,
                                userName: _fullNameController.text,
                                userPhone: _phoneController.text,
                                userAddress: _addressController.text,
                                userBirthday: _selectedDate!,
                                userProfilePictureUrl: uploadedPictureUrl,
                                webImage: _webImage,
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Password is not strong enough',
                                  ),
                                ),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Passwords do not match')),
                            );
                          }
                        }
                      },
                      child: Text('Register'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 80,
                          vertical: 18,
                        ),
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Already have an account? Login',
                        style: TextStyle(
                          color: Colors.white,
                        ), // <-- Here is the white text color
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(
    TextEditingController controller,
    String hintText,
    IconData icon, {
    bool isEmail = false,
    bool isPhone = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          hintText: hintText,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15),
        ),
        keyboardType: isEmail
            ? TextInputType.emailAddress
            : isPhone
            ? TextInputType.phone
            : TextInputType.text,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'This field is required';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordField(
    TextEditingController controller,
    String hintText,
    bool isVisible,
    VoidCallback toggleVisibility,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: !isVisible,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.lock),
          hintText: hintText,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15),
          suffixIcon: IconButton(
            icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off),
            onPressed: toggleVisibility,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'This field is required';
          }
          return null;
        },
      ),
    );
  }
}
