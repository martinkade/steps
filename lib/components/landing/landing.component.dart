import 'package:flutter/material.dart';
import 'package:steps/components/shared/bezier.clipper.dart';

class Landing extends StatefulWidget {
  ///
  final String title;

  ///
  Landing({Key key, this.title}) : super(key: key);

  @override
  _LandingState createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ClipPath(
            clipper: BezierClipper(),
            child: Container(
              height: 192.0,
              color: Color.fromARGB(255, 255, 215, 0),
            ),
          ),
          Container()
        ],
      ),
    );
  }
}
