import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import '../l10n/app_localizations.dart';
import 'dart:convert';
import 'dart:typed_data';

class RecipeDetailsPage extends StatefulWidget {
  final String docId;

  RecipeDetailsPage({required this.docId});

  @override
  _RecipeDetailsPageState createState() => _RecipeDetailsPageState();
}

class _RecipeDetailsPageState extends State<RecipeDetailsPage> {
  final TextEditingController _commentController = TextEditingController();
  bool _favoriteChanged = false;

  Future<void> _addComment() async {
    String comment = _commentController.text.trim();
    if (comment.isEmpty) return;

    try {
      DocumentReference recipeRef = FirebaseFirestore.instance
          .collection('recipes')
          .doc(widget.docId);

      await recipeRef.update({
        'comments': FieldValue.arrayUnion([comment]),
      });

      _commentController.clear();
      setState(() {});
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Comment added!')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _downloadRecipeAsPDF(
    String title,
    String description,
    List<String> ingredients,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(description, style: pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 20),
              pw.Text(
                'Ingredients:',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: ingredients
                    .map((ingredient) => pw.Bullet(text: ingredient))
                    .toList(),
              ),
            ],
          );
        },
      ),
    );

    try {
      // Get the temporary directory of the device
      final output = await getTemporaryDirectory();
      final file = File(
        "${output.path}/recipe_${DateTime.now().millisecondsSinceEpoch}.pdf",
      );
      await file.writeAsBytes(await pdf.save());

      // Open the PDF file (optional)
      await OpenFile.open(file.path);

      print('PDF saved to ${file.path}');

      // Optionally, show a snackbar or toast that PDF is saved
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('PDF downloaded to ${file.path}')));
    } catch (e) {
      print('Error saving PDF: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save PDF: $e')));
    }
  }

  void _toggleFavorite(bool isFavorite) async {
    try {
      await FirebaseFirestore.instance
          .collection('recipes')
          .doc(widget.docId)
          .update({'favorite': isFavorite});

      setState(() {
        _favoriteChanged = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFavorite ? 'Added to Favorites!' : 'Removed from Favorites!',
          ),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _shareRecipe(
    String title,
    String description,
    List<String> ingredients,
    String imageUrl,
  ) {
    print('Share function called');
    String ingredientList = ingredients.join(', ');
    String content =
        '''
Check out this recipe!

$title

$description

Ingredients: $ingredientList
${imageUrl.isNotEmpty ? '\nImage: $imageUrl' : ''}

Shared via MyRecipeApp
''';
    Share.share(content);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _favoriteChanged);
        return false;
      },
      child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('recipes')
            .doc(widget.docId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return Scaffold(body: Center(child: CircularProgressIndicator()));
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

          var data = snapshot.data!.data() as Map<String, dynamic>;
          String recipeName = data['title'] ?? 'Unnamed Recipe';
          String recipeDescription = data['description'] ?? '';
          String recipeImage = data['image'] ?? '';
          Uint8List? imageBytes = _decodeBase64Image(recipeImage);

          ImageProvider imageProvider;

          if (imageBytes != null) {
            imageProvider = MemoryImage(imageBytes);
          } else {
            imageProvider = NetworkImage(recipeImage);
          }

          List<String> recipeIngredients =
              (data['recipeIngredients'] as List<dynamic>?)
                  ?.map((item) => item.toString())
                  .toList() ??
              [];
          int recipePreparationTime = data['preparationTime'] ?? 0;
          bool isFavorite = data['favorite'] ?? false;
          List<dynamic> comments = data['comments'] ?? [];

          return Scaffold(
            appBar: AppBar(
              title: Text(recipeName),
              backgroundColor: Colors.white,
              actions: [
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                  ),
                  color: Colors.red,
                  onPressed: () => _toggleFavorite(!isFavorite),
                ),
                IconButton(
                  icon: Icon(Icons.share),
                  onPressed: () => _shareRecipe(
                    recipeName,
                    recipeDescription,
                    recipeIngredients,
                    recipeImage,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.picture_as_pdf),
                  onPressed: () => _downloadRecipeAsPDF(
                    recipeName,
                    recipeDescription,
                    recipeIngredients,
                  ),
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Image(
                      image: imageProvider,
                      fit: BoxFit.cover,
                      height: 250,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 250,
                          color: Colors.grey[300],
                          child: Center(
                            child: Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                              size: 50,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    recipeName,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    recipeDescription,
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.ingredients,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: recipeIngredients
                        .map(
                          (ingredient) => Row(
                            children: [
                              Icon(Icons.check, color: Colors.green, size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  ingredient,
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.access_time, color: Colors.grey),
                      SizedBox(width: 8),
                      Text(
                        '${AppLocalizations.of(context)!.preparationTime} $recipePreparationTime minutes',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  // Comment Input Field
                  Text(
                    AppLocalizations.of(context)!.leaveAComment,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: InputDecoration(
                            hintText: 'Write a comment...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _addComment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        child: Icon(Icons.send, color: Colors.white),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  // Comments Section
                  Text(
                    AppLocalizations.of(context)!.comments,

                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  comments.isEmpty
                      ? Text(
                          AppLocalizations.of(context)!.noCommentsMessage,

                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        )
                      : Column(
                          children: comments.map((comment) {
                            return Container(
                              padding: EdgeInsets.all(12),
                              margin: EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.comment, color: Colors.grey[700]),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      comment,
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
