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

  // Vokabel bearbeiten
  Future<void> updateVocabulary(Vocabulary vocabulary) async {
    try {
      await _vocabulariesCollection.doc(vocabulary.id).update(vocabulary.toMap());
    } catch (e) {
      throw Exception('Fehler beim Bearbeiten der Vokabel: $e');
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

  // Zufällige Vokabeln für Lernmodus
  Future<List<Vocabulary>> getRandomVocabularies({int limit = 10}) async {
    try {
      QuerySnapshot snapshot = await _vocabulariesCollection.get();
      List<Vocabulary> allVocabularies = snapshot.docs
          .map((doc) => Vocabulary.fromFirestore(doc))
          .toList();
      
      if (allVocabularies.isEmpty) return [];
      
      // Mische die Liste und nimm die ersten 'limit' Elemente
      allVocabularies.shuffle();
      return allVocabularies.take(limit).toList();
    } catch (e) {
      throw Exception('Fehler beim Laden der Lernvokabeln: $e');
    }
  }
}