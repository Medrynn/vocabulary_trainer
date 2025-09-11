import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  User? get currentUser => _auth.currentUser;
  
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Registrierung
  Future<String?> registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      notifyListeners();
      return null; // Erfolg
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          return 'Das Passwort ist zu schwach.';
        case 'email-already-in-use':
          return 'E-Mail wird bereits verwendet.';
        case 'invalid-email':
          return 'Ungültige E-Mail-Adresse.';
        default:
          return 'Registrierung fehlgeschlagen: ${e.message}';
      }
    } catch (e) {
      return 'Ein unerwarteter Fehler ist aufgetreten.';
    }
  }

  // Anmeldung
  Future<String?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      notifyListeners();
      return null; // Erfolg
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'Benutzer nicht gefunden.';
        case 'wrong-password':
          return 'Falsches Passwort.';
        case 'invalid-email':
          return 'Ungültige E-Mail-Adresse.';
        case 'user-disabled':
          return 'Benutzer wurde deaktiviert.';
        default:
          return 'Anmeldung fehlgeschlagen: ${e.message}';
      }
    } catch (e) {
      return 'Ein unerwarteter Fehler ist aufgetreten.';
    }
  }

  // Abmeldung
  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }
}