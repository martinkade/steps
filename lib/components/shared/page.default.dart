import 'package:flutter/material.dart';

class DefaultPage extends StatelessWidget {
  ///
  final Widget child;

  ///
  final String title;

  ///
  DefaultPage({Key? key, required this.child, required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Theme.of(context).textTheme.bodyText1?.color,
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24.0,
            color: Theme.of(context).textTheme.bodyText1?.color,
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          child: child,
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
      ),
    );
  }
}
