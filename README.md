# Vokabeltrainer

Eine Flutter-App zum Lernen von Vokabeln mit Firebase-Integration

## App-Name und Beschreibung

**Vokabeltrainer** ist eine mobile Anwendung zum Verwalten und Lernen von Vokabeln. Die App ermöglicht es Benutzern, sich sicher anzumelden und ihre persönlichen Vokabelsammlungen in verschiedenen Sprachen zu erstellen und zu verwalten.

## Funktionen

- Benutzer-Authentifizierung mit E-Mail und Passwort
- Persönliche Vokabeln hinzufügen, anzeigen und löschen
- Unterstützung für 8 verschiedene Sprachen
- Responsive Design für verschiedene Bildschirmgrössen

## Installation

1. Repository klonen

    git clone https://github.com/Medrynn/vocabulary_trainer.git
    cd vocabulary_trainer

2. Dependencies installieren

    flutter pub get

3. App starten

    flutter run


## Projektstruktur

    lib/
    ├── main.dart                    # App-Einstiegspunkt
    ├── models/
    │   └── vocabulary.dart          # Vokabel-Datenmodell
    ├── services/
    │   ├── auth_service.dart        # Firebase Authentication
    │   └── firestore_service.dart   # Firestore Database
    └── screens/
        ├── auth_wrapper.dart        # Authentication Routing
        ├── auth_screen.dart         # Login/Registrierung
        ├── home_screen.dart         # Vokabel-Übersicht
        └── add_vocabulary_screen.dart # Neue Vokabel hinzufügen

## Technologie-Stack

- Flutter 3.x
- Firebase Authentication
- Cloud Firestore

## Modul

TEKO Schweizerische Fachschule AG  
Mobile Apps
Abgabe: 11. September 2025