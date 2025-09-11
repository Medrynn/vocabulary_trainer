import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/vocabulary.dart';

class FirestoreService {
  final CollectionReference _vocabulariesCollection = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('vocabularies');

  // Vokabel hinzufügen
  Future<void> addVocabulary(Vocabulary vocabulary) async {
    try {
      await _vocabulariesCollection.add(vocabulary.toMap());
    } catch (e) {
      throw Exception('Fehler beim Hinzufügen der Vokabel: $e');
    }
  }

  // Alle Vokabeln des Users abrufen
  Stream<List<Vocabulary>> getVocabularies() {
    return _vocabulariesCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Vocabulary.fromFirestore(doc))
            .toList());
  }

  // Vokabel löschen
  Future<void> deleteVocabulary(String id) async {
    try {
      await _vocabulariesCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Fehler beim Löschen der Vokabel: $e');
    }
  }

  // Vokabel-Statistiken abrufen
  Future<int> getVocabularyCount() async {
    try {
      QuerySnapshot snapshot = await _vocabulariesCollection.get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }
}