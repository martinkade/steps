import 'package:flutter/material.dart';
import 'package:steps/components/shared/localizer.dart';

class DashboardInfoItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
      child: Card(
        elevation: 8.0,
        shadowColor: Colors.grey.withAlpha(50),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Container(
          child: Padding(
            child: Center(
              child: Text(
                Localizer.translate(context, 'lblDashboardInfo').replaceFirst(
                  '%1',
                  Localizer.translate(context, 'appName').toUpperCase(),
                ),
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
          ),
          color: Colors.blue.withAlpha(50),
        ),
      ),
    );
  }
}
