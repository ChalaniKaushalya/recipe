import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:typed_data';

class RecipeCard extends StatefulWidget {
  final Map<String, dynamic> recipies;
  final String docId; // Document ID
  final VoidCallback onTap;

  RecipeCard({
    required this.recipies,
    required this.docId,
    required this.onTap,
  });

  @override
  _RecipeCardState createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.recipies['favorite'] ?? false;
  }

  @override
  void didUpdateWidget(covariant RecipeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.recipies['favorite'] != widget.recipies['favorite']) {
      setState(() {
        isFavorite = widget.recipies['favorite'] ?? false;
      });
    }
  }

  void toggleFavorite() async {
    setState(() {
      isFavorite = !isFavorite;
    });

    try {
      await FirebaseFirestore.instance
          .collection('recipes')
          .doc(widget.docId)
          .update({'favorite': isFavorite});
    } catch (e) {
      print("Error updating favorite status: $e");
      setState(() {
        isFavorite = !isFavorite;
      });
    }
  }

  Uint8List? _decodeBase64Image(String? imageData) {
    if (imageData == null || !imageData.contains(',')) return null;
    try {
      final base64Str = imageData.split(',').last;
      return base64Decode(base64Str);
    } catch (e) {
      print("Error decoding image: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageBytes = _decodeBase64Image(widget.recipies['image']);

    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            // Image Section
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: imageBytes != null
                    ? Image.memory(
                        imageBytes,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: const Center(child: Icon(Icons.image)),
                      ),
              ),
            ),

            // Title and Favorite
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.recipies['title'] ?? 'No Title',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.grey,
                    ),
                    onPressed: toggleFavorite,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
