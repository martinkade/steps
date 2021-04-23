import 'dart:io' show Platform;
import 'package:firebase_core/firebase_core.dart';
import 'package:wandr/__secrets.dart';

class Storage {
  FirebaseApp _app;
  static final Storage _instance = Storage._internal();
  factory Storage() => _instance;
  Storage._internal();

  Future<FirebaseApp> access() async {
    if (_app == null) {
      _app = await Firebase.initializeApp(
        name: 'jovial-engine-286206',
        options: Platform.isIOS
            ? const FirebaseOptions(
                appId: IOS_APP_ID,
                apiKey: API_KEY,
                projectId: 'jovial-engine-286206',
                databaseURL: DATABASE_URL,
                messagingSenderId: GCM_SENDER_ID,
              )
            : const FirebaseOptions(
                appId: ANDROID_APP_ID,
                apiKey: API_KEY,
                projectId: 'jovial-engine-286206',
                databaseURL: DATABASE_URL,
                messagingSenderId: GCM_SENDER_ID,
              ),
      );
    }
    return _app;
  }
}
