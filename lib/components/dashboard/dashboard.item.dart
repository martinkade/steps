import 'package:flutter/material.dart';

abstract class DashboardItem extends StatefulWidget {
  final String title;
  DashboardItem({Key key, this.title}) : super(key: key);
}
