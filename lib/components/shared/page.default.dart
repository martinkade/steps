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
      backgroundColor: Color.fromARGB(255, 255, 215, 0),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    child: Icon(
                      Icons.arrow_back,
                      size: 32.0,
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16.0),
            ),
            Expanded(
              child: Container(
                color: Colors.white,
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
