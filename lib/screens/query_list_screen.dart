import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QueryListScreen extends StatefulWidget {
  const QueryListScreen({super.key});

  @override
  _QueryListScreenState createState() => _QueryListScreenState();
}

class _QueryListScreenState extends State<QueryListScreen> {
  String? _selectedTag;
  final List<String> _tags = [
    'All',
    'Fertilizers',
    'Pest Control',
    'Crop Diseases',
    'Weather & Irrigation',
    'Organic Farming',
    'Machinery & Tools',
    'Market Prices',
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        
        padding: const EdgeInsets.fromLTRB(16, 35, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Community Queries",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedTag ?? 'All',
              decoration: InputDecoration(
                labelText: "Filter by Category",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              items: _tags.map((tag) {
                return DropdownMenuItem(
                  value: tag,
                  child: Text(tag),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTag = value;
                });
              },
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder(
                stream: _selectedTag == null || _selectedTag == 'All'
                    ? FirebaseFirestore.instance
                        .collection('queries')
                        .orderBy('timestamp', descending: true)
                        .snapshots()
                    : FirebaseFirestore.instance
                        .collection('queries')
                        .where('tag', isEqualTo: _selectedTag)
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No queries found for this category."));
                  }

                  return ListView(
                    padding: const EdgeInsets.only(top: 5),
                    children: snapshot.data!.docs.map((doc) {
                      return QueryCard(queryDoc: doc);
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QueryCard extends StatelessWidget {
  final QueryDocumentSnapshot queryDoc;

  const QueryCard({super.key, required this.queryDoc});

  @override
  Widget build(BuildContext context) {
    final data = queryDoc.data() as Map<String, dynamic>;
    final String queryText = data['query'] ?? '';
    final String? imageUrl = data['image_url'];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: const Color.fromARGB(255, 244, 245, 230),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              queryText,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            if (imageUrl != null && imageUrl.isNotEmpty) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      child: InteractiveViewer(
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    imageUrl,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 200,
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                          child: Text("Failed to load image", style: TextStyle(color: Colors.red)));
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "By: ${data['username']}",
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  data['tag'],
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ],
            ),
            const Divider(height: 20),
            ReplyList(queryId: queryDoc.id),
            ReplyInputField(queryId: queryDoc.id),
          ],
        ),
      ),
    );
  }
}

class ReplyList extends StatelessWidget {
  final String queryId;

  const ReplyList({super.key, required this.queryId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('queries')
          .doc(queryId)
          .collection('replies')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              "No replies yet",
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.grey),
            ),
          );
        }

        return Column(
          children: snapshot.data!.docs.map((replyDoc) {
            return Container(
              margin: const EdgeInsets.only(top: 5),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                title: Text(replyDoc['reply'], style: const TextStyle(fontSize: 16)),
                subtitle: Text("By: ${replyDoc['username']}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class ReplyInputField extends StatefulWidget {
  final String queryId;

  const ReplyInputField({super.key, required this.queryId});

  @override
  ReplyInputFieldState createState() => ReplyInputFieldState();
}

class ReplyInputFieldState extends State<ReplyInputField> {
  final TextEditingController _replyController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _postReply() async {
    if (_replyController.text.trim().isEmpty) return;

    final User? user = _auth.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('queries')
          .doc(widget.queryId)
          .collection('replies')
          .add({
        'reply': _replyController.text.trim(),
        'username': user.displayName ?? 'Anonymous',
        'timestamp': FieldValue.serverTimestamp(),
      });

      _replyController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _replyController,
              decoration: InputDecoration(
                hintText: "Write a reply...",
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _postReply,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
