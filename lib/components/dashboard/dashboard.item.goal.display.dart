import 'package:flutter/material.dart';
import 'package:wandr/components/shared/progress.text.animated.dart';

enum DashboardGoalDisplayType {
  DAILY,
  WEEKLY,
}

class DashboardGoalDisplay extends StatelessWidget {
  ///
  final int start, end, estimated, target;

  ///
  final String label, text;

  ///
  final DashboardGoalDisplayType displayType;

  ///
  const DashboardGoalDisplay({
    Key? key,
    required this.displayType,
    this.start = 0,
    required this.end,
    this.estimated = -1,
    required this.target,
    required this.label,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedProgressText(
          start: this.start,
          end: this.end,
          estimated: this.estimated,
          target: this.target,
          fontSize:
              this.displayType == DashboardGoalDisplayType.DAILY ? 48.0 : 32.0,
          label: this.label,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            this.text,
            style: TextStyle(fontSize: 13.0),
          ),
        ),
      ],
    );
  }
}
