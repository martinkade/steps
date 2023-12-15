import 'package:flutter/material.dart';
import 'package:wandr/components/shared/localizer.dart';
import 'package:wandr/components/shared/page.default.dart';
import 'package:wandr/components/teams/teams.item.create.dialog.dart';
import 'package:wandr/components/teams/teams.item.record.dart';
import 'package:wandr/model/fit.team.dart';
import 'package:wandr/model/preferences.dart';
import 'package:wandr/model/repositories/fitness.repository.dart';

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
  late List<FitTeam> _teams = <FitTeam>[];

  ///
  late List<String> _users = <String>[];

  ///
  FitTeam? _myTeam;

  ///
  final FitnessRepository _repository = FitnessRepository();

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

    _repository.fetchAvailableTeamList().then((teams) {
      if (!mounted) {
        return;
      }
      _teams.clear();
      setState(() {
        _teams.addAll(teams);
      });
    });
  }

  void _showCreateTeamDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: TeamsCreateDialog(
              teams: _teams,
              createTeam: (newTeamName) {
              },
            ),
          );
        }).then((_) {
      setState(() {});
    });
  }

  void _showEnterTeamDialog(FitTeam team) {
    Widget cancelButton = TextButton(
      child: Text(Localizer.translate(context, 'lblActionCancel')),
      onPressed: () => Navigator.of(context).pop()
    );
    Widget continueButton = TextButton(
      child: Text(Localizer.translate(context, 'lblActionEnterTeam')),
      onPressed: () {
        Navigator.of(context).pop();
        _enterTeam(team);
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(Localizer.translate(context, 'lblTeamsEnterDialogTitle')),
      content: Text(Localizer.translate(context, 'lblTeamsEnterDialogDescription')
          .replaceFirst(
        '%1',
        team.name ?? "",
      ),),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void _enterTeam(FitTeam team) {
    Preferences.setTeam(team).then((value) {
      if (!mounted) {
        return;
      }
      setState(() {
        _myTeam = team;
      });
    });
  }

  void _showLeaveTeamDialog() {
    Widget cancelButton = TextButton(
        child: Text(Localizer.translate(context, 'lblActionCancel')),
        onPressed: () => Navigator.of(context).pop()
    );
    Widget continueButton = TextButton(
      child: Text(Localizer.translate(context, 'lblActionLeaveTeam')),
      onPressed: () {
        Navigator.of(context).pop();
        _leaveTeam();
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(Localizer.translate(context, 'lblTeamsLeaveDialogTitle')),
      content: Text(Localizer.translate(context, 'lblTeamsLeaveDialogDescription')
          .replaceFirst(
        '%1',
        _myTeam?.name ?? "",
      ),),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void _leaveTeam() {
    Preferences.removeTeam().then((value) {
      if (!mounted) {
        return;
      }
      setState(() {
        _myTeam = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_myTeam != null) {
      return DefaultPage(
        child: Card(
          elevation: 8.0,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: ListView.builder(
            itemCount: _users.length + 2,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 20.0),
                  child: Center(
                    child: Text(
                      _myTeam?.name ?? "",
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              } else if (index == (_users.length + 1)) {
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
                      color: Theme.of(context).colorScheme.primary.withAlpha(50),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
                        child: Column(
                          children: [
                            GestureDetector(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
                                child: Center(
                                  child: Text(
                                    Localizer.translate(context, 'lblActionLeaveTeam'),
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              onTap: () => _showLeaveTeamDialog(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                return Text(_users[index - 1]);
              }
            },
          ),
        ),
        title: Localizer.translate(context, 'lblTeams'),
      );
    } else {
      return DefaultPage(
        child: Card(
          elevation: 8.0,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: ListView.builder(
            itemCount: _teams.length + 1,
            itemBuilder: (context, index) {
              if (index == _teams.length) {
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
                      color: Theme.of(context).colorScheme.primary.withAlpha(50),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
                        child: Column(
                          children: [
                            GestureDetector(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
                                child: Center(
                                  child: Text(
                                    Localizer.translate(context, 'lblActionCreateTeam'),
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              onTap: () => _showCreateTeamDialog(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                return GestureDetector(
                  child: TeamRecordItem(
                    team: _teams[index],
                  ),
                  onTap: () {
                    _showEnterTeamDialog(_teams[index]);
                  },
                );
              }
            },
          ),
        ),
        title: Localizer.translate(context, 'lblTeams'),
      );
    }
  }
}
