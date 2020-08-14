import 'dart:io' show Platform;
import 'package:firebase_core/firebase_core.dart';

class Storage {
  FirebaseApp _app;
  static final Storage _instance = Storage._internal();
  factory Storage() => _instance;
  Storage._internal() {}

  Future<FirebaseApp> access() async {
    if (_app == null) {
      _app = await FirebaseApp.configure(
        name: 'db',
        options: Platform.isIOS
            ? const FirebaseOptions(
                googleAppID: '1:42298583733:ios:a77f31b494c48fefbaecfc',
                gcmSenderID: '42298583733',
                databaseURL: 'https://jovial-engine-286206.firebaseio.com/',
              )
            : const FirebaseOptions(
                googleAppID: '1:42298583733:android:bf2de8626fe1bb00baecfc',
                apiKey: 'AIzaSyAQxMNw-X0T-9qJcy9D_WkpH7s3W1enADM',
                databaseURL: 'https://jovial-engine-286206.firebaseio.com/',
              ),
      );
    }
    return _app;
  }
}
