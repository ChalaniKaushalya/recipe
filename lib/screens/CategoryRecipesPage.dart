import 'package:flutter/material.dart';

class CategoryRecipesPage extends StatelessWidget {
  final String category;

  CategoryRecipesPage({required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$category Recipes'),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: Text(
          'Recipes for $category will be displayed here!',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
