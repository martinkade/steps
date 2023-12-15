import 'package:flutter/material.dart';
import 'package:wandr/components/shared/localizer.dart';
import 'package:wandr/components/shared/page.default.dart';
import 'package:wandr/components/teams/teams.item.create.dialog.dart';
import 'package:wandr/components/teams/teams.item.record.dart';
import 'package:wandr/model/fit.team.dart';
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
  final FitnessRepository _repository = FitnessRepository();

  @override
  void initState() {
    super.initState();

    /*
    _repository.fetchTeams().then((teams) {
      if (!mounted) {
        return;
      }
      _teams.clear();
      setState(() {
        _teams.addAll(teams);
      });
    });
    */

    _teams = [FitTeam("Testteam", 3), FitTeam("Testteam2", 5), FitTeam("Azubis", 1), FitTeam("Frontend", 12)];
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
        team.name,
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
    if (widget.userKey == null || team.users.any((element) => team.name == widget.userKey)) {
      return;
    }
    team.users.add(widget.userKey ?? "");
    //_repository.updateTeam(team);
  }

  @override
  Widget build(BuildContext context) {
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
