import 'package:flutter/material.dart';
import 'dart:async'; // For delay
import 'start_page.dart';

// Splash Screen
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Delay for 5 seconds before navigating to the main page
    Timer(Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              StartPage(), // Navigate to StartPage after 5 seconds
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 133, 128, 128), // Background color for splash screen
      body: Stack(
        children: [
          // Background Image (Cover the whole screen)
          Positioned.fill(
            child: Image.asset(
              'assets/222.jpeg', // Set the correct background image path
              fit: BoxFit.cover, // Image will cover the screen
            ),
          ),
          // Optional Overlay Gradient to darken the background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Centered Circular Icon (Using Image)
          Center(
            child: CircleAvatar(
              radius: 60.0, // Adjust radius of the circle as needed
              backgroundColor: const Color.fromARGB(255, 150, 114, 114), // Circle background color
              backgroundImage: AssetImage('assets/333.jpeg'), // Set icon image
            ),
          ),
        ],
      ),
    );
  }
}
