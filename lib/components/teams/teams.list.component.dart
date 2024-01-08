import 'package:flutter/material.dart';
import 'package:wandr/components/shared/localizer.dart';
import 'package:wandr/components/shared/page.default.dart';
import 'package:wandr/components/teams/teams.item.create.dialog.dart';
import 'package:wandr/components/teams/teams.item.record.dart';
import 'package:wandr/model/fit.team.dart';
import 'package:wandr/model/preferences.dart';
import 'package:wandr/model/repositories/fitness.repository.dart';

class TeamsListComponent extends StatefulWidget {
  ///
  final String? userKey;

  ///
  final Function enterTeam;

  ///
  const TeamsListComponent({Key? key, this.userKey, required this.enterTeam})
      : super(key: key);

  @override
  _TeamsListState createState() => _TeamsListState();
}

class _TeamsListState extends State<TeamsListComponent> {
  ///
  late List<FitTeam> _teams = <FitTeam>[];

  ///
  final FitnessRepository _repository = FitnessRepository();

  @override
  void initState() {
    super.initState();

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
                _createTeam(newTeamName);
              },
            ),
          );
        });
  }

  void _showEnterTeamDialog(FitTeam team) {
    Widget cancelButton = TextButton(
        child: Text(Localizer.translate(context, 'lblActionCancel')),
        onPressed: () => Navigator.of(context).pop());
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
      content: Text(
        Localizer.translate(context, 'lblTeamsEnterDialogDescription')
            .replaceFirst(
          '%1',
          team.name ?? "",
        ),
      ),
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

  void _createTeam(String teamName) {
    _repository.addTeam(FitTeam(name: teamName));
  }

  void _enterTeam(FitTeam team) {
    Preferences.setTeam(team).then((value) => widget.enterTeam(team));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultPage(
      title: Localizer.translate(context, 'lblTeams'),
      child:  SingleChildScrollView(
    child:SizedBox(
    height: MediaQuery.of(context).size.height,
    child:Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 16.0),
            child: Text(
              Localizer.translate(
                  context, 'lblTeamsMotivation'),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
            child: Card(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _teams.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    child: TeamRecordItem(
                      team: _teams[index],
                    ),
                    onTap: () {
                      _showEnterTeamDialog(_teams[index]);
                    },
                  );
                },
              ),
            ),
          ),
          Padding(
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
                          padding:
                              const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
                          child: Center(
                            child: Text(
                              Localizer.translate(
                                  context, 'lblActionCreateTeam'),
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
          )
        ],
      ),
      ),
      ),
    );
  }
}
