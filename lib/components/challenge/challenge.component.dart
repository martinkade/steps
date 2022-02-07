import 'package:flutter/material.dart';
import 'package:wandr/components/challenge/challenge.item.map.dart';
import 'package:wandr/components/shared/bezier.clipper.dart';
import 'package:wandr/components/shared/localizer.dart';
import 'package:wandr/components/shared/progress.text.animated.dart';
import 'package:wandr/model/calendar.dart';
import 'package:wandr/model/fit.challenge.dart';
import 'package:intl/intl.dart';

class Challenge extends StatefulWidget {
  ///
  final FitChallenge challenge;

  ///
  final int index;

  ///
  Challenge({Key key, this.challenge, this.index}) : super(key: key);

  @override
  _ChallengeState createState() => _ChallengeState();
}

class _ChallengeState extends State<Challenge> {
  ///
  final Calendar _calendar = Calendar();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width - 32.0;
    final double height = width * 0.67;
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? Colors.yellow
          : Colors.black,
      body: SafeArea(
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipPath(
                clipper: BezierClipper(leftHeight: 0.9, rightHeight: 0.67),
                child: Container(
                  height: 256.0,
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.yellow
                      : Colors.black,
                ),
              ),
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Hero(
                        child: Card(
                          elevation: 8.0,
                          shadowColor: Colors.grey.withAlpha(50),
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Container(
                            height: height,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(widget.challenge.imageAsset),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Icon(
                                          Icons.arrow_back,
                                        ),
                                      ),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Theme.of(context)
                                            .scaffoldBackgroundColor,
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                Expanded(
                                  child: Container(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        tag: 'challenge-${widget.index}',
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(14.0, 8.0, 14.0, 0.0),
                        child: Text(
                          widget.challenge.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                      widget.challenge.isUpcoming(
                              calendar: _calendar, date: DateTime.now())
                          ? Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  14.0, 0.0, 14.0, 16.0),
                              child: Text(
                                Localizer.translate(
                                        context, 'lblChallengeStartDate')
                                    .replaceFirst(
                                  '%1',
                                  DateFormat.yMMMMEEEEd(LOCALE ?? 'de_DE')
                                      .format(widget.challenge.startDate),
                                ),
                              ),
                            )
                          : (widget.challenge.isCompleted
                              ? Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      14.0, 0.0, 14.0, 16.0),
                                  child: Text(
                                    Localizer.translate(
                                        context, 'lblChallengeSuccess'),
                                  ),
                                )
                              : (widget.challenge.isExpired(
                                      calendar: _calendar, date: DateTime.now())
                                  ? Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          14.0, 0.0, 14.0, 16.0),
                                      child: Text(
                                        Localizer.translate(
                                                context, 'lblChallengeExpired')
                                            .replaceFirst(
                                          '%1',
                                          DateFormat.yMMMMEEEEd(
                                                  LOCALE ?? 'de_DE')
                                              .format(widget.challenge.endDate),
                                        ),
                                      ),
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          14.0, 0.0, 14.0, 16.0),
                                      child: Text(
                                        Localizer.translate(
                                                context, 'lblChallengeEndDate')
                                            .replaceFirst(
                                          '%1',
                                          DateFormat.yMMMMEEEEd(
                                                  LOCALE ?? 'de_DE')
                                              .format(widget.challenge.endDate),
                                        ),
                                      ),
                                    ))),
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(14.0, 8.0, 14.0, 32.0),
                        child: Text(
                          widget.challenge.description,
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(14.0, 8.0, 14.0, 8.0),
                        child: AnimatedProgressText(
                          start: 0,
                          end: widget.challenge.progress.toInt(),
                          estimated: widget.challenge.estimated.toInt(),
                          target: widget.challenge.target.toInt(),
                          fontSize: 48.0,
                          label: widget.challenge.label,
                        ),
                      ),
                      widget.challenge.routeAsset != null && widget.challenge.routeAsset.isNotEmpty ?
                        Card(
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Container(
                              height: 400.0,
                              child: ChallengeMap(
                                  challenge: widget.challenge
                              )
                          ),
                        ) : Container()
                    ]
                  )
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
