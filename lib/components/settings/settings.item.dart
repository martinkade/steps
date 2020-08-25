import 'package:flutter/material.dart';

abstract class SettingsItem extends StatefulWidget {
  final String title;
  SettingsItem({Key key, this.title})
      : super(key: key);
}
