class Post {
  String id;
  String title;
  String description;
  String tag;
  String userId;
  DateTime createdAt;

  Post({required this.id, required this.title, required this.description, required this.tag, required this.userId, required this.createdAt});

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'tag': tag,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static Post fromMap(String id, Map<String, dynamic> data) {
    return Post(
      id: id,
      title: data['title'],
      description: data['description'],
      tag: data['tag'],
      userId: data['userId'],
      createdAt: DateTime.parse(data['createdAt']),
    );
  }
}
