import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:steps/components/landing/landing.item.dart';
import 'package:steps/components/shared/localizer.dart';

class LandingIdentityItem extends LandingItem {
  ///
  LandingIdentityItem({Key key, int index, LandingDelegate delegate})
      : super(key: key, index: index, delegate: delegate);

  @override
  _LandingIdentityItemState createState() => _LandingIdentityItemState();
}

class _LandingIdentityItemState extends State<LandingIdentityItem> {
  ///
  TextEditingController _inputController;

  ///
  String _email;

  @override
  void initState() {
    super.initState();

    _inputController = TextEditingController();

    SharedPreferences.getInstance().then((preferences) {
      final String userValue = preferences.getString('kUser');
      if (!mounted) return;
      setState(() {
        _inputController.text = userValue;
        _email = userValue;
      });
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  bool _validate(String value) {
    final String text = value.toLowerCase();
    final bool valid =
        RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@mediabeam.com")
            .hasMatch(text);
    if (valid) {
      SharedPreferences.getInstance().then((preferences) {
        if (!mounted) return;
        preferences.setString('kUser', text);
        print('updated shared preference user key value to $text');
      });
      setState(() {
        _email = text;
      });
    } else {
      setState(() {
        _email = null;
      });
    }
    return valid;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
          child: Text(
            Localizer.translate(context, 'lblLandingText2'),
            textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 0.0),
            child: TextField(
              keyboardType: TextInputType.emailAddress,
              controller: _inputController,
              onChanged: (value) {
                _validate(value);
              },
              onSubmitted: (value) {
                _validate(value);
              },
              obscureText: false,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: Localizer.translate(context, 'lblEmail'),
              ),
            ),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FlatButton(
              child: Text(
                Localizer.translate(context, 'lblActionBack'),
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.normal,
                ),
              ),
              onPressed: () {
                widget.delegate.previousItem(widget);
              },
            ),
            FlatButton(
              disabledTextColor: Colors.grey,
              child: Text(
                Localizer.translate(context, 'lblActionForward'),
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: _email == null
                  ? null
                  : () {
                      widget.delegate.nextItem(widget);
                    },
            ),
          ],
        )
      ],
    );
  }
}
