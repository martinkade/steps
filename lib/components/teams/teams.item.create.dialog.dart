import 'package:flutter/material.dart';
import 'package:wandr/components/shared/localizer.dart';
import 'package:wandr/model/fit.team.dart';

class TeamsCreateDialog extends StatefulWidget {
  final Function createTeam;

  final List<FitTeam> teams;

  const TeamsCreateDialog({
    required this.createTeam,
    required this.teams,
  });

  @override
  _TeamsCreateDialog createState() =>
      _TeamsCreateDialog();
}

class _TeamsCreateDialog
    extends State<TeamsCreateDialog> {
  ///
  late TextEditingController _inputController;

  ///
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();

    _inputController = TextEditingController();
    _focusNode = FocusNode();
  }

  bool _validate(String value) {
    final String text = value;
    if (text.isEmpty || text.length < 2) {
      return false;
    }
    
    if (widget.teams.any((element) => element.name == text)) {
      return false;
    }
    return true;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: max(312.0, MediaQuery.of(context).size.height * 0.33),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              Localizer.translate(context, 'lblTeamsTeamNameTitle'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0.0, 32.0, 0.0, 8.0),
              child: TextField(
                keyboardType: TextInputType.name,
                controller: _inputController,
                autofillHints: [AutofillHints.name],
                focusNode: _focusNode,
                onChanged: (value) {
                  _validate(value);
                },
                onSubmitted: (value) {
                  _validate(value);
                },
                obscureText: false,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: Localizer.translate(
                      context, 'lblTeamsTeamNameTitle'),
                ),
              ),
            ),
            TextButton(
              child: Text(
                Localizer.translate(context, 'lblActionCreateTeam'),
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () => widget.createTeam(_inputController.text),
            ),
          ],
        ),
      ),
    );
  }
}