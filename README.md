# Chat App

A multi-platform real-time chat application built with Flutter and Firebase.

## Features (V1)

- **Google OAuth authentication** — sign in / sign out with Google
- **1-to-1 real-time text chat** — Firestore-powered live messaging
- **Push notifications** — FCM-based notifications with foreground + background handling
- **Clean architecture** — feature-based folder structure, Riverpod state management
- **Cross-platform** — Android, iOS, Web

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.x |
| Auth | Firebase Auth + Google Sign-In |
| Database | Cloud Firestore |
| Notifications | Firebase Cloud Messaging |
| State Management | Riverpod |
| Routing | go_router |
| Backend Logic | Firebase Cloud Functions (Node.js) |

## Project Structure

```
lib/
├── core/
│   ├── constants/    # App-wide constants
│   ├── services/     # Firebase service abstractions
│   └── utils/        # Date formatters, helpers
├── features/
│   ├── auth/         # Login screen
│   ├── chat/         # Chat screen, message bubbles, input
│   └── home/         # Conversation list, new chat
├── models/           # Data models (User, Conversation, Message)
├── providers/        # Riverpod providers
├── routes/           # GoRouter configuration
└── main.dart         # Entry point
```

## Setup

### Prerequisites

- Flutter SDK 3.x
- Firebase project with Auth, Firestore, and Cloud Messaging enabled
- `flutterfire` CLI configured

### Install dependencies

```bash
flutter pub get
```

### Firebase setup

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable Google Sign-In in Authentication
3. Create a Firestore database
4. Run `flutterfire configure` to generate `firebase_options.dart`
5. Deploy Firestore rules: `firebase deploy --only firestore:rules`
6. Deploy indexes: `firebase deploy --only firestore:indexes`
7. Deploy Cloud Functions: `cd functions && npm install && firebase deploy --only functions`

### Run

```bash
# Web
flutter run -d web-server --web-port=8080

# Android/iOS
flutter run
```

### Test

```bash
flutter test
```

## Firestore Security Rules

Security rules enforce:
- Users can only read/write their own user document
- Only conversation members can read/write conversations and messages
- Message sender ID must match authenticated user

See `firestore.rules` for the complete ruleset.

## Cloud Functions

`functions/index.js` contains a Firestore trigger that sends FCM push notifications to the recipient when a new message is created.
