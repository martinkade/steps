import 'package:flutter/material.dart';
import 'package:steps/app.dart';
import 'package:steps/model/storage.dart';

void main() async {
  // establish Firebase connection
  WidgetsFlutterBinding.ensureInitialized();
  Storage().access().then((instance) {
    // then launching app
    runApp(App());
  });
}
