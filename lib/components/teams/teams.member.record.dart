import 'package:flutter/material.dart';
import 'package:wandr/model/fit.team.dart';

import 'package:wandr/components/shared/localizer.dart';

class TeamMemberItem extends StatefulWidget {
  ///
  final String name;

  ///
  final int points;

  ///
  final bool unitKilometersEnabled;

  ///
  TeamMemberItem({
    Key? key,
    required this.name,
    required this.points,
    required this.unitKilometersEnabled
  }) : super(key: key);

  @override
  _TeamRecordItemState createState() => _TeamRecordItemState();
}

class _TeamRecordItemState extends State<TeamMemberItem> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                  widget.name,
                style: TextStyle(
                  fontSize: 16.0
                ),
              ),
            ),
                  Text(
    widget.unitKilometersEnabled
                        ? (widget.points / 12.0).toStringAsFixed(1)
                        : widget.points.toStringAsFixed(0),
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),
                          child: Text(
                            widget.unitKilometersEnabled
                                ? Localizer.translate(context, 'lblUnitKilometer')
                                : Localizer.translate(context, 'lblUnitPoints'),
                          ),
                  )

        ]
      )
    );
  }
}
