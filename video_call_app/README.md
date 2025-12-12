# video_call_app

Flutter video/audio calling app using GetX, Firebase Firestore, and flutter_webrtc.

Features

- GetX folder structure with bindings, controllers, and views
- Firestore-based signaling (offer/answer + ICE)
- WebRTC peer connection with local/remote video
- Basic call controls (mute, camera enable, switch, hangup)

Folder Structure (lib/app)

- routes/ → `app_routes.dart`, `app_pages.dart`
- services/ → `webrtc_service.dart`, `firestore_signaling_service.dart`
- modules/
  - lobby/ → `lobby_binding.dart`, `lobby_controller.dart`, `lobby_view.dart`
  - call/ → `call_binding.dart`, `call_controller.dart`, `call_view.dart`

Setup

1. Install dependencies

   ```bash
   flutter pub get
   ```

2. Configure Firebase for each platform

   - Run FlutterFire CLI to add Firebase: https://firebase.google.com/docs/flutter/setup
   - Example:

   ```bash
   flutter pub global activate flutterfire_cli
   flutterfire configure --project <your-firebase-project-id>
   ```

   This will generate platform configs (Android/iOS/Web/etc.) used by `firebase_core`.

3. Enable Firestore in Firebase Console and create rules suitable for development:
   - For local testing only, you can use:
   ```
   rules_version = '2';
   service cloud.firestore {
   	 match /databases/{database}/documents {
   		 match /{document=**} {
   			 allow read, write: if true; // Development only
   		 }
   	 }
   }
   ```

Run

- Web:
  ```bash
  flutter run -d chrome
  ```
- Android:
  ```bash
  flutter run -d android
  ```
- iOS (macOS required):
  ```bash
  flutter run -d ios
  ```

Usage

- From the Lobby screen, tap "Videocall" to create a new room and start a call as caller.
- Share the room ID with another device, and use "Join Room" to join.

Notes

- Screen share, chat, whiteboard, and file share buttons are placeholders.
- For production: secure Firestore rules, use TURN servers for NAT traversal, and handle disconnect cleanup robustly.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
