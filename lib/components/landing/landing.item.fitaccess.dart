import 'package:flutter/material.dart';
import 'package:steps/components/landing/landing.item.dart';
import 'package:steps/components/shared/localizer.dart';
import 'dart:io' show Platform;

import 'package:steps/model/repositories/fitness.repository.dart';

class LandingFitAccessItem extends LandingItem {
  ///
  LandingFitAccessItem({Key key, int index, LandingDelegate delegate})
      : super(key: key, index: index, delegate: delegate);

  @override
  _LandingFitAccessItemState createState() => _LandingFitAccessItemState();
}

class _LandingFitAccessItemState extends State<LandingFitAccessItem> {
  ///
  final FitnessRepository _repository = FitnessRepository();

  ///
  bool _isAuthorized = false;

  @override
  void initState() {
    super.initState();

    load();
  }

  void load() {
    _repository.hasPermissions().then((authorized) {
      if (!mounted) return;
      setState(() {
        _isAuthorized = authorized;
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
            Platform.isIOS
                ? Localizer.translate(context, 'lblLandingText3Apple')
                : Localizer.translate(context, 'lblLandingText3Google'),
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  child: Image.asset(Platform.isIOS
                      ? 'assets/images/fit_apple.png'
                      : 'assets/images/fit_google.png'),
                  width: 44.0,
                  height: 44.0,
                ),
                Padding(
                  child: _isAuthorized
                      ? Icon(
                          Icons.check_circle_outline,
                          size: 32.0,
                          color: Colors.green,
                        )
                      : FlatButton(
                          onPressed: () {
                            _repository.requestPermissions().then((authorized) {
                              if (!mounted) return;
                              setState(() {
                                _isAuthorized = authorized;
                              });
                            });
                          },
                          child: Text(
                            Localizer.translate(context, 'lblActionGrant'),
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                  padding: const EdgeInsets.all(16.0),
                ),
              ],
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
              child: Text(
                Localizer.translate(context, 'lblActionDone'),
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                widget.delegate.nextItem(widget);
              },
            ),
          ],
        )
      ],
    );
  }
}
