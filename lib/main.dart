import 'package:flutter/material.dart';
import 'package:wandr/app.dart';
import 'package:wandr/model/storage.dart';

void main() async {
  // establish Firebase connection
  WidgetsFlutterBinding.ensureInitialized();
  Storage().access().then((instance) {
    // then launching app
    runApp(App());
  });
}
