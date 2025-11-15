import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wandr/components/landing/landing.item.dart';
import 'package:wandr/components/shared/localizer.dart';
import 'package:wandr/model/xworksclient/xworksapi.error.dart';
import 'package:wandr/model/xworksclient/xworksapi.module.auth.dart';
import 'package:wandr/model/xworksclient/xworksapi.module.dart';

class LandingIdentityItem extends LandingItem {
  ///
  LandingIdentityItem(
      {Key? key, required int index, required LandingDelegate delegate})
      : super(key: key, index: index, delegate: delegate);

  @override
  _LandingIdentityItemState createState() => _LandingIdentityItemState();
}

class _LandingIdentityItemState extends State<LandingIdentityItem> {
  ///
  late TextEditingController _emailController, _passwordController;

  ///
  late FocusNode _emailFocusNode, _passwordFocusNode;

  ///
  String? _email, _password;

  ///
  ///
  late XworksApiAuthModule _apiAuthModule;
  bool _isAuthenticating = false;
  XworksApiError? _authenticationError;

  @override
  void initState() {
    super.initState();

    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
    _apiAuthModule = XworksApiAuthModule(XworksApiModule.defaultApiClient);

    SharedPreferences.getInstance().then((preferences) {
      final String? userValue = preferences.getString('kUser');
      if (!mounted) return;
      setState(() {
        _emailController.text = userValue ?? '';
        _email = userValue;
      });
    });
  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _emailController.dispose();
    _passwordFocusNode.dispose();
    _passwordController.dispose();
    _apiAuthModule.dispose();
    super.dispose();
  }

  bool _validateEmail(String value) {
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

  bool _validatePassword(String value) {
    final String text = value.toLowerCase();
    final bool valid =
        RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+").hasMatch(text);
    if (valid) {
      setState(() {
        _password = text;
      });
    } else {
      setState(() {
        _password = null;
      });
    }
    return valid;
  }

  void _login() {
    setState(() {
      _isAuthenticating = true;
    });
    _apiAuthModule
        .getToken(
      username: _emailController.text,
      password: _passwordController.text,
    )
        .then(
      (response) {
        widget.delegate.nextItem(widget);
      },
    ).catchError(
      (ex) {
        setState(() {
          _authenticationError = ex;
        });
      },
    ).whenComplete(() {
      setState(() {
        _isAuthenticating = false;
      });
    });
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
            child: _isAuthenticating || _authenticationError != null
                ? Column(
                    spacing: 16.0,
                    children: [
                      _authenticationError == null
                          ? Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 0.0),
                              child: CircularProgressIndicator(),
                            )
                          : Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Icon(Icons.error),
                            ),
                      _authenticationError == null
                          ? Text(
                              Localizer.translate(context, 'lblSigningIn'),
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.normal,
                              ),
                            )
                          : Text(
                              Localizer.translate(
                                  context, _authenticationError!.messageKey),
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.normal,
                              ),
                            )
                    ],
                  )
                : AutofillGroup(
                    child: Column(
                      spacing: 16.0,
                      children: [
                        TextField(
                          keyboardType: TextInputType.emailAddress,
                          controller: _emailController,
                          autofillHints: [AutofillHints.email],
                          focusNode: _emailFocusNode,
                          onChanged: (value) {
                            _validateEmail(value);
                          },
                          onSubmitted: (value) {
                            _validateEmail(value);
                          },
                          obscureText: false,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: Localizer.translate(context, 'lblEmail'),
                          ),
                        ),
                        TextField(
                          keyboardType: TextInputType.visiblePassword,
                          controller: _passwordController,
                          autofillHints: [AutofillHints.password],
                          focusNode: _passwordFocusNode,
                          onChanged: (value) {
                            _validatePassword(value);
                          },
                          onSubmitted: (value) {
                            _validatePassword(value);
                          },
                          obscureText: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText:
                                Localizer.translate(context, 'lblPassword'),
                          ),
                        )
                      ],
                    ),
                  ),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
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
            TextButton(
              child: Text(
                Localizer.translate(context, 'lblActionForward'),
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed:
                  _email == null || _password == null || _isAuthenticating
                      ? null
                      : () {
                          _login();
                        },
            ),
          ],
        )
      ],
    );
  }
}
