import 'package:flutter/material.dart';
import 'package:wandr/components/teams/teams.list.component.dart';
import 'package:wandr/components/teams/teams.team.component.dart';
import 'package:wandr/model/fit.team.dart';
import 'package:wandr/model/preferences.dart';

class TeamsComponent extends StatefulWidget {
  ///
  final String? userKey;

  ///
  const TeamsComponent({Key? key, this.userKey}) : super(key: key);

  @override
  _TeamsState createState() => _TeamsState();
}

class _TeamsState extends State<TeamsComponent> {

  ///
  FitTeam? _myTeam;

  @override
  void initState() {
    super.initState();

    Preferences.getTeam().then((team) {
        if (!mounted) {
            return;
        }
        setState(() {
          _myTeam = team;
        });
    });
  }

  void _enterTeam(FitTeam team) {
    setState(() {
      _myTeam = team;
    });
  }

  void _leaveTeam() {
    setState(() {
      _myTeam = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_myTeam != null) {
      return TeamsTeamComponent(
          myTeam: _myTeam,
          userKey: widget.userKey,
          leaveTeam: () => _leaveTeam()
      );
    } else {
      return TeamsListComponent(
          userKey: widget.userKey,
          enterTeam: (team) => _enterTeam(team)
      );
    }
  }
}
