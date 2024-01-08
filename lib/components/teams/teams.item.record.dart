import 'package:flutter/material.dart';
import 'package:wandr/model/fit.team.dart';

import 'package:wandr/components/shared/localizer.dart';

class TeamRecordItem extends StatefulWidget {
  ///
  final FitTeam team;

  ///
  TeamRecordItem({
    Key? key,
    required this.team
  }) : super(key: key);

  @override
  _TeamRecordItemState createState() => _TeamRecordItemState();
}

class _TeamRecordItemState extends State<TeamRecordItem> {
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
                  widget.team.name ?? "",
                style: TextStyle(
                  fontSize: 16.0
                ),
              ),
            ),
          Text(
            Localizer.translate(context, 'lblActionEnterTeam'),
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.end,
          ),
        ]
      )
    );
  }
}
