import 'package:flutter/material.dart';

class ContactUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Contact Us',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black), // Back icon color
      ),
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image:
                    AssetImage('assets/background.jpg'), // Path to your image
                fit: BoxFit.cover, // Adjust to cover entire screen
              ),
            ),
          ),

          // Foreground Content
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),

                    // Welcome Text and Intro inside a White Card
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white
                            .withOpacity(0.9), // Slight transparency
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Welcome Text
                          Text(
                            'Welcome to RecipeMate!',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 10),

                          // Intro Text
                          Text(
                            'At RecipeMate, we are dedicated to bringing you the best recipes from around the world. If you have any questions or need support, feel free to reach out to us through the contact information below. We are always happy to assist you!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),

                    // Contact Us Card
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white
                            .withOpacity(0.9), // Slight transparency
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Heading
                          Text(
                            'Contact Us',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 20),

                          // Email Row
                          Row(
                            children: [
                              Icon(Icons.email, color: Colors.black),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'support@recipemate.com',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 15),

                          // Phone Row
                          Row(
                            children: [
                              Icon(Icons.phone, color: Colors.black),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '0765721662',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 15),

                          // Location Row (Optional)
                          // Row(
                          //   children: [
                          //     Icon(Icons.location_on, color: Colors.black),
                          //     SizedBox(width: 10),
                          //     Expanded(
                          //       child: Text(
                          //         '123 Main Street, City, Country',
                          //         style: TextStyle(fontSize: 16),
                          //       ),
                          //     ),
                          //   ],
                          // ),
                        ],
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
}
