import 'package:cloud_firestore/cloud_firestore.dart';

class Vocabulary {
  final String? id;
  final String german;
  final String foreign;
  final String language;
  final DateTime createdAt;

  Vocabulary({
    this.id,
    required this.german,
    required this.foreign,
    required this.language,
    required this.createdAt,
  });

  // Von Firestore DocumentSnapshot erstellen
  factory Vocabulary.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Vocabulary(
      id: doc.id,
      german: data['german'] ?? '',
      foreign: data['foreign'] ?? '',
      language: data['language'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // Zu Firestore Map konvertieren
  Map<String, dynamic> toMap() {
    return {
      'german': german,
      'foreign': foreign,
      'language': language,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}