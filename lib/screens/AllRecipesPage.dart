import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class AllRecipesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.allRecipes),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: Text(
          'All available recipes will be displayed here!',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
