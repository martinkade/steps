import 'dart:io' show Platform;
import 'package:firebase_core/firebase_core.dart';
import 'package:wandr/__secrets.dart';

class Storage {
  FirebaseApp? _app;
  static final Storage _instance = Storage._internal();
  factory Storage() => _instance;
  Storage._internal();

  Future<FirebaseApp?> access() async {
    const String projectName = 'jovial-engine-286206';
    if (_app == null) {
      if (Firebase.apps.isEmpty) {
        try {
          _app = await Firebase.initializeApp(
            name: projectName,
            options: Platform.isIOS
                ? const FirebaseOptions(
                    appId: IOS_APP_ID,
                    apiKey: API_KEY,
                    projectId: projectName,
                    databaseURL: DATABASE_URL,
                    messagingSenderId: GCM_SENDER_ID,
                  )
                : const FirebaseOptions(
                    appId: ANDROID_APP_ID,
                    apiKey: API_KEY,
                    projectId: projectName,
                    databaseURL: DATABASE_URL,
                    messagingSenderId: GCM_SENDER_ID,
                  ),
          );
        } catch (_) {
          _app = Firebase.app(projectName);
        }
      } else {
        _app = Firebase.app('jovial-engine-286206');
      }
    }
    return _app;
  }
}
