import 'package:cloud_firestore/cloud_firestore.dart';

class SearchHistory {
  final String id;
  final String keyword;
  final DateTime timestamp;

  SearchHistory({
    required this.id,
    required this.keyword,
    required this.timestamp,
  });

  factory SearchHistory.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return SearchHistory(
      id: doc.id,
      keyword: data['keyword'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
