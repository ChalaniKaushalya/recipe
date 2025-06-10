import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  late bool isFavorite;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.recipies['favorite'] ?? false;
  }

  @override
  void didUpdateWidget(covariant RecipeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When the widget updates, check if the favorite status has changed
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
      // If update fails, revert the local change.
      setState(() {
        isFavorite = !isFavorite;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.recipies['image'],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[300],
                    child: Center(child: Icon(Icons.image)),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.recipies['title'],
                      style: TextStyle(fontWeight: FontWeight.bold),
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
