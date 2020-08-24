import 'dart:io' show Platform;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:steps/components/shared/localizer.dart';

class DashboardInfoDialogContent extends StatelessWidget {
  final Function onDismiss;
  DashboardInfoDialogContent({this.onDismiss});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: max(312.0, MediaQuery.of(context).size.height * 0.33),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      child: Image.asset('assets/images/landing.png'),
                      width: 192.0,
                      height: 128.0,
                    ),
                    Text(
                      Localizer.translate(context, 'lblDashboardInfoText')
                          .replaceAll(
                        '%1',
                        Localizer.translate(context, 'appName').toUpperCase(),
                      ),
                      textAlign: TextAlign.start,
                      style: TextStyle(fontSize: 16.0),
                    )
                  ],
                ),
              ),
            ),
            FlatButton(
              child: Text(
                Localizer.translate(context, 'lblActionDone'),
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: onDismiss,
            )
          ],
        ),
      ),
    );
  }
}
