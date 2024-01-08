import 'package:flutter/material.dart';
import 'package:wandr/components/shared/localizer.dart';
import 'package:wandr/components/shared/page.default.dart';
import 'package:wandr/components/teams/teams.member.record.dart';
import 'package:wandr/model/fit.team.dart';
import 'package:wandr/model/fit.user.dart';
import 'package:wandr/model/preferences.dart';
import 'package:wandr/model/repositories/fitness.repository.dart';

class TeamsTeamComponent extends StatefulWidget {
  ///
  final String? userKey;

  ///
  final FitTeam? myTeam;

  ///
  final Function leaveTeam;

  ///
  const TeamsTeamComponent(
      {Key? key, this.userKey, this.myTeam, required this.leaveTeam})
      : super(key: key);

  @override
  _TeamsTeamState createState() => _TeamsTeamState();
}

class _TeamsTeamState extends State<TeamsTeamComponent> {
  ///
  late List<FitUser> _users = <FitUser>[];

  ///
  final FitnessRepository _repository = FitnessRepository();

  ///
  bool _unitKilometersEnabled = false;

  @override
  void initState() {
    super.initState();

    Preferences().isFlagSet(kFlagUnitKilometers).then((enabled) {
      setState(() {
        _unitKilometersEnabled = enabled;
      });
    });

    _repository.readUsers().then((users) {
      if (!mounted) {
        return;
      }
      _users.clear();
      setState(() {
        _users.addAll(users);
      });
    });
  }

  void _showLeaveTeamDialog() {
    Widget cancelButton = TextButton(
        child: Text(Localizer.translate(context, 'lblActionCancel')),
        onPressed: () => Navigator.of(context).pop());
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
      content: Text(
        Localizer.translate(context, 'lblTeamsLeaveDialogDescription')
            .replaceFirst(
          '%1',
          widget.myTeam?.name ?? "",
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

  void _leaveTeam() {
    FitTeam? myTeam = widget.myTeam;

    final List<FitUser> users =
        _users.where((element) => myTeam?.name == element.team).toList();
    if (users.length <= 1 && myTeam != null) {
      print('Delete team "${myTeam.name}"');
      _repository.deleteTeam(myTeam);
    }
    print('Leave team "${myTeam?.name ?? ''}"');
    Preferences.removeTeam().then((value) => widget.leaveTeam());
  }

  @override
  Widget build(BuildContext context) {
    final List<FitUser> users =
        _users.where((element) => widget.myTeam?.name == element.team).toList();
    return DefaultPage(
        title: Localizer.translate(context, 'lblTeams'),
        child: ListView.builder(
          itemCount: 4,
          itemBuilder: (context, index) {
            switch (index) {
              case 0:
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 20.0),
                  child: Center(
                    child: Text(
                      widget.myTeam?.name ?? "",
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              case 1:
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 20.0),
                  child: Center(
                    child: Text(
                      Localizer.translate(
                          context, 'lblTeamsMembersInfo'),
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                );
              case 2:
                return Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
                  child: Card(
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        return TeamMemberItem(
                              name: users[index].name ?? "",
                          points: users[index].today ?? 0,
                            unitKilometersEnabled: _unitKilometersEnabled
                        );
                      },
                    ),
                  ),
                );
              default:
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
                      color:
                          Theme.of(context).colorScheme.primary.withAlpha(50),
                      child: Padding(
                        padding:
                            const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
                        child: Column(
                          children: [
                            GestureDetector(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    16.0, 8.0, 16.0, 16.0),
                                child: Center(
                                  child: Text(
                                    Localizer.translate(
                                        context, 'lblActionLeaveTeam'),
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
            }
          },
        )
      );
  }
}
