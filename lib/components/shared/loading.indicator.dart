import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wandr/components/shared/localizer.dart';

class LoadingIndicator extends StatelessWidget {
  ///
  final double height;

  ///
  const LoadingIndicator({Key key, this.height = 192.0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                Localizer.translate(context, 'lblLoading'),
              ),
            ),
          ],
        ),
      ),
      height: min(this.height, 96.0),
    );
  }
}
