import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PostQueryScreen extends StatefulWidget {
  final VoidCallback onPostComplete;

  const PostQueryScreen({super.key, required this.onPostComplete});

  @override
  _PostQueryScreenState createState() => _PostQueryScreenState();
}

class _PostQueryScreenState extends State<PostQueryScreen> {
  final TextEditingController _queryController = TextEditingController();
  String? _selectedTag;
  File? _image;
  bool _isPosting = false;

  final List<String> _tags = [
    'Fertilizers', 'Pest Control', 'Crop Diseases',
    'Weather & Irrigation', 'Organic Farming', 'Machinery & Tools', 'Market Prices',
  ];

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(String queryId) async {
    if (_image == null) return null;
    try {
      final fileName = 'queries/$queryId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = FirebaseStorage.instance.ref().child(fileName);
      await storageRef.putFile(_image!);
      return await storageRef.getDownloadURL();
    } catch (e) {
      print('Image Upload Error: $e');
      return null;
    }
  }

  Future<void> _uploadQuery() async {
    if (_queryController.text.trim().isEmpty || _selectedTag == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a question and select a category")),
      );
      return;
    }

    setState(() => _isPosting = true);

    try {
      final firebase_auth.User? user = firebase_auth.FirebaseAuth.instance.currentUser;
      if (user != null) {
        String queryId = FirebaseFirestore.instance.collection('queries').doc().id;
        String? imageUrl = await _uploadImage(queryId);

        await FirebaseFirestore.instance.collection('queries').doc(queryId).set({
          'query': _queryController.text.trim(),
          'tag': _selectedTag,
          'timestamp': Timestamp.now(),
          'username': user.displayName ?? user.email ?? 'Anonymous',
          'userId': user.uid,
          'image_url': imageUrl,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Your query has been posted!")),
        );

        widget.onPostComplete();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please sign in to post a query")),
        );
      }
    } catch (e) {
      print("Error in uploadQuery: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred. Please try again.")),
      );
    }

    setState(() => _isPosting = false);
  }

  void _showImagePreview() {
    if (_image != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Center(
                child: InteractiveViewer(
                  child: Image.file(
                    _image!,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headingStyle = theme.textTheme.headlineMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: Colors.black87,
      fontSize: 28, // Consistent font size across pages
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Ask a Question", style: headingStyle),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Your Question", style: theme.textTheme.titleMedium?.copyWith(fontSize: 18), ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _queryController,
                      maxLines: 5,
                      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 16),
                      decoration: InputDecoration(
                        hintText: "Type your question here...",
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.all(16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text("Select a Category", style: theme.textTheme.titleMedium?.copyWith(fontSize: 18)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedTag,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: _tags
                          .map((tag) => DropdownMenuItem(value: tag, child: Text(tag)))
                          .toList(),
                      onChanged: (value) => setState(() => _selectedTag = value),
                    ),
                    const SizedBox(height: 20),

                    Text("Add Image (optional)", style: theme.textTheme.titleMedium?.copyWith(fontSize: 18)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () => _pickImage(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt_outlined),
                          tooltip: 'Take Photo',
                          splashColor: Colors.blue.withOpacity(0.3),
                          hoverColor: Colors.blue.withOpacity(0.1),
                        ),
                        IconButton(
                          onPressed: () => _pickImage(ImageSource.gallery),
                          icon: const Icon(Icons.image_outlined),
                          tooltip: 'Choose from Gallery',
                          splashColor: Colors.blue.withOpacity(0.3),
                          hoverColor: Colors.blue.withOpacity(0.1),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (_image != null)
                      GestureDetector(
                        onTap: _showImagePreview,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _image!,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    else
                      const Text("No image selected", style: TextStyle(color: Colors.grey)),

                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isPosting ? null : _uploadQuery,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.green.shade300,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                        ),
                        child: _isPosting
                            ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                            : const Text(
                                "Post Query",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
