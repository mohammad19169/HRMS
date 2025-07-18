class Announcement {
  final String id;
  final String title;
  final String content;
  final DateTime postedAt;
  final String postedBy;

  Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.postedAt,
    required this.postedBy,
  });

  factory Announcement.fromMap(Map<String, dynamic> data, String id) {
    return Announcement(
      id: id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      postedAt: data['postedAt'].toDate(),
      postedBy: data['postedBy'] ?? '',
    );
  }
}