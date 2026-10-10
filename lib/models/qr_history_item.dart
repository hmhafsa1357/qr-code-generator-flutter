/// A single saved QR code entry, kept in local storage (SharedPreferences)
/// so the history screen has something to show between app launches.
class QrHistoryItem {
  final String content;
  final String type; // "Text", "URL", or "Contact"
  final DateTime createdAt;

  QrHistoryItem({
    required this.content,
    required this.type,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'content': content,
    'type': type,
    'createdAt': createdAt.toIso8601String(),
  };

  factory QrHistoryItem.fromJson(Map<String, dynamic> json) => QrHistoryItem(
    content: json['content'] as String,
    type: json['type'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}