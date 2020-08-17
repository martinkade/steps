import 'dart:io' show Platform;
import 'package:firebase_core/firebase_core.dart';
import 'package:steps/__secrets.dart';

class Storage {
  FirebaseApp _app;
  static final Storage _instance = Storage._internal();
  factory Storage() => _instance;
  Storage._internal() {}

  Future<FirebaseApp> access() async {
    if (_app == null) {
      _app = await FirebaseApp.configure(
        name: 'jovial-engine-286206',
        options: Platform.isIOS
            ? const FirebaseOptions(
                googleAppID: IOS_APP_ID,
                apiKey: API_KEY,
                databaseURL: DATABASE_URL,
                gcmSenderID: GCM_SENDER_ID,
              )
            : const FirebaseOptions(
                googleAppID: ANDROID_APP_ID,
                apiKey: API_KEY,
                databaseURL: DATABASE_URL,
              ),
      );
    }
    return _app;
  }
}
