import 'package:flutter/material.dart';
import 'package:wandr/components/shared/localizer.dart';
import 'package:wandr/model/preferences.dart';

class DashboardSettingsDisplayNameDialog extends StatefulWidget {
  final Function setDisplayName;

  const DashboardSettingsDisplayNameDialog({
    required this.setDisplayName,
  });

  @override
  _DashboardSettingsDisplayNameDialog createState() =>
      _DashboardSettingsDisplayNameDialog();
}

class _DashboardSettingsDisplayNameDialog
    extends State<DashboardSettingsDisplayNameDialog> {
  ///
  late TextEditingController _inputController;

  ///
  late FocusNode _focusNode;

  ///
  String? _displayName;

  @override
  void initState() {
    super.initState();

    _inputController = TextEditingController();
    _focusNode = FocusNode();

    Preferences().getDisplayName().then((name) {
      if (!mounted) return;
      setState(() {
        _inputController.text = name;
        _displayName = name;
      });
    });
  }

  bool _validate(String value) {
    final String text = value;
    final bool valid = true;
    if (valid) {
      Preferences().setDisplayName(text).then((preferences) {
        if (!mounted) return;
        setState(() {
          _displayName = text;
        });
      });
    }
    return valid;
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
              Localizer.translate(context, 'lblSettingsDisplayNameMainTitle'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0.0, 32.0, 0.0, 8.0),
              child: TextField(
                keyboardType: TextInputType.emailAddress,
                controller: _inputController,
                autofillHints: [AutofillHints.email],
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
                      context, 'lblSettingsDisplayNameMainTitle'),
                ),
              ),
            ),
            TextButton(
              child: Text(
                Localizer.translate(context, 'lblActionDone'),
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () => widget.setDisplayName(_displayName),
            ),
          ],
        ),
      ),
    );
  }
}
