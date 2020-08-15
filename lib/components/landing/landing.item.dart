import 'package:flutter/material.dart';

abstract class LandingDelegate {
  void previousItem(LandingItem item);
  void nextItem(LandingItem item);
}

abstract class LandingItem extends StatefulWidget {
  final int index;
  final LandingDelegate delegate;
  LandingItem({Key key, this.index, this.delegate}) : super(key: key);
}
