# Setup instructions (Firebase + Stream + Local token server)

This scaffold provides a ready-to-integrate `lib/` folder with:
- Firebase Firestore repository code
- Contacts fetching (flutter_contacts)
- Stream Chat integration (StreamService)
- Cubit-based state management (AuthCubit, ContactsCubit)

## 1) Install required Flutter packages
Add these to your `pubspec.yaml` (versions may vary):
```
firebase_core: ^2.10.0
cloud_firestore: ^4.8.0
flutter_bloc: ^8.1.2
stream_chat_flutter: ^9.16.0
http: ^0.13.6
flutter_contacts: ^0.9.2
permission_handler: ^10.4.0
```
Run:
```
flutter pub get
```

## 2) Configure Firebase (FlutterFire CLI)
Install FlutterFire CLI and run:
```
dart pub global activate flutterfire_cli
flutterfire configure
```
Pick your Firebase project and platforms (Android/iOS). This will generate `lib/firebase_options.dart` — replace the placeholder file included here.

## 3) Android / iOS platform config
- Android: add permissions to `android/app/src/main/AndroidManifest.xml`:
  ```xml
  <uses-permission android:name="android.permission.READ_CONTACTS"/>
  <uses-permission android:name="android.permission.INTERNET"/>
  ```
  Also follow Firebase console steps: add Android app, provide package name, download `google-services.json`, place in `android/app/`.

- iOS: follow Firebase console steps and place `GoogleService-Info.plist` in Runner.

## 4) Stream Chat setup
- Create a Stream app at https://getstream.io and copy the API key.
- Paste the API key into `lib/services/stream_service.dart` (replace the placeholder).
- For production tokens, you must run a backend token server that uses your Stream API secret to create tokens.

## 5) Local token server (Node.js example)
Create `token-server/index.js` with the following (example uses `stream-chat` package):
```js
// Node.js minimal token server
const express = require('express');
const { StreamChat } = require('stream-chat');
const app = express();
const apiKey = process.env.STREAM_API_KEY;
const apiSecret = process.env.STREAM_API_SECRET;
const serverClient = new StreamChat(apiKey, apiSecret);

app.get('/token', (req, res) => {
  const userId = req.query.user_id;
  if (!userId) return res.status(400).send({error: 'user_id required'});
  const token = serverClient.createToken(userId);
  res.json({ token });
});

app.listen(3000, () => console.log('Token server running on 3000'));
```
Run:
```
npm install express stream-chat
STREAM_API_KEY=your_key STREAM_API_SECRET=your_secret node index.js
```
- For Android emulator, use `http://10.0.2.2:3000/token?user_id=...` in `StreamService.tokenUrl`.
- For physical devices, use your machine LAN IP.

## 6) Run the app
- Ensure `lib/firebase_options.dart` is replaced by generated one.
- Ensure token server is running (or set `useDevToken = true` inside `StreamService` for development only).
- Run:
```
flutter run
```

## Notes
- This scaffold is ready but needs your Firebase project and Stream API credentials.
- I cannot run the CLI or modify your local files from here — follow steps above to complete setup.
