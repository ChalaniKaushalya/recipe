import 'package:flutter/material.dart';
import 'package:recipeapplication/l10n/app_localizations.dart';

class SettingsPage extends StatelessWidget {
  final Map<String, dynamic> userProfileData = {
    'email': 'chalani417@gmail.com',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(AppLocalizations.of(context)!.settingsHeader),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(Icons.person),
              title: Text(AppLocalizations.of(context)!.profileHeader),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/viewProfile',
                  arguments: userProfileData,
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.contact_mail),
              title: Text(AppLocalizations.of(context)!.aboutUs),
              onTap: () {
                Navigator.pushNamed(context, '/contactUs');
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text(AppLocalizations.of(context)!.logout),
              onTap: () {
                _showLogoutConfirmation(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Log Out'),
          content: Text('Are you sure you want to exit?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Stay on settings page
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(
                  context,
                ).pushReplacementNamed('/login'); // Navigate to login page
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
