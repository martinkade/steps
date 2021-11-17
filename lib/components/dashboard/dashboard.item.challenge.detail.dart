import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:wandr/components/shared/localizer.dart';
import 'package:wandr/components/shared/progress.text.animated.dart';
import 'package:wandr/model/calendar.dart';
import 'package:wandr/model/fit.challenge.dart';
import 'package:intl/intl.dart';

class DashboardChallengeDetail extends StatefulWidget {
  ///
  final FitChallenge challenge;

  ///
  final int index;

  ///
  DashboardChallengeDetail({Key key, this.challenge, this.index})
      : super(key: key);

  @override
  _DashboardChallengeDetailState createState() =>
      _DashboardChallengeDetailState();
}

class _DashboardChallengeDetailState extends State<DashboardChallengeDetail> {
  ///
  final Calendar _calendar = Calendar();

  @override
  void initState() {
    super.initState();

    setState(() {
      widget.challenge.load();
    });
  }

  Widget _overlay(BuildContext context, FitChallenge challenge) {
    final Duration delta =
        challenge.getStartDateDelta(calendar: _calendar, date: DateTime.now());
    if (challenge.isUpcoming(calendar: _calendar, date: DateTime.now())) {
      String deltaText =
          Localizer.translate(context, 'lblChallengeDeltaDaysMany')
              .replaceFirst('%1', (delta.inDays + 1).toString());
      if (delta.inDays == 1) {
        deltaText = Localizer.translate(context, 'lblChallengeDeltaDaysOne');
      } else if (delta.inDays == 0) {
        deltaText = Localizer.translate(context, 'lblChallengeDeltaDaysZero')
            .replaceFirst('%1', (delta.inHours + 1).toString());
      }
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
        child: Container(
          color: Colors.black.withOpacity(0.1),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.timer),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
                  child: Text(
                    challenge.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                  child: Text(deltaText),
                ),
              ],
            ),
          ),
        ),
      );
    } else if (challenge.isCompleted) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
        child: Container(
          color: Colors.black.withOpacity(0.1),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_outline),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
                  child: Text(
                    challenge.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                  child: Text(
                    Localizer.translate(context, 'lblChallengeSuccess'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else if (challenge.isExpired(calendar: _calendar, date: DateTime.now())) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
        child: Container(
          color: Colors.black.withOpacity(0.1),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.block_rounded),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
                  child: Text(
                    challenge.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                  child: Text(
                    Localizer.translate(context, 'lblChallengeExpired')
                        .replaceFirst(
                      '%1',
                      DateFormat.yMMMMEEEEd(LOCALE ?? 'de_DE')
                          .format(widget.challenge.endDate),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color overlayColor = Theme.of(context).brightness == Brightness.light
        ? Colors.white
        : Colors.black;
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(widget.challenge.imageAsset),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [overlayColor.withAlpha(10), overlayColor.withAlpha(205)],
              stops: [0.1, 0.9],
              begin: Alignment.topRight,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Container(),
              ),
              AnimatedProgressText(
                start: 0,
                end: widget.challenge.progress.toInt(),
                estimated: widget.challenge.estimated.toInt(),
                target: widget.challenge.target.toInt(),
                fontSize: 32.0,
                label: widget.challenge.label,
                animated: false,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  widget.challenge.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
              ),
              Text(
                widget.challenge.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.normal),
              ),
            ],
          ),
        ),
        _overlay(context, widget.challenge),
      ],
    );
  }
}
