import 'package:flutter/material.dart';

class BezierClipper extends CustomClipper<Path> {
  ///
  final double leftHeight;

  ///
  final double rightHeight;

  ///
  BezierClipper({this.leftHeight = 0.75, this.rightHeight = 0.75});

  @override
  Path getClip(Size size) {
    final Path path = Path();
    path.lineTo(0.0, size.height * leftHeight);
    path.quadraticBezierTo(
        size.width * 0.5, size.height, size.width, size.height * rightHeight);
    path.lineTo(size.width, 0.0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
