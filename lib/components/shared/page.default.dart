import 'package:flutter/material.dart';

class DefaultPage extends StatelessWidget {
  ///
  final Widget child;

  ///
  final String title;

  ///
  DefaultPage({Key key, this.child, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        backgroundColor: Color.fromARGB(255, 255, 215, 0),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24.0,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: child,
        ),
      ),
    );
  }
}
