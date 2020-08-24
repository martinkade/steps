import 'package:flutter/material.dart';

abstract class SettingsItem extends StatefulWidget {
  final String title;
  final String description;
  final String label;
  SettingsItem({Key key, this.title, this.description, this.label})
      : super(key: key);
}
