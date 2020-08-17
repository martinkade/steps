import 'package:flutter/material.dart';
import 'package:steps/model/fit.challenge.dart';

class DashboardChallengeDetail extends StatefulWidget {
  ///
  final FitChallenge challenge;

  ///
  DashboardChallengeDetail({Key key, this.challenge}) : super(key: key);

  @override
  _DashboardChallengeDetailState createState() =>
      _DashboardChallengeDetailState();
}

class _DashboardChallengeDetailState extends State<DashboardChallengeDetail> {
  @override
  void initState() {
    super.initState();

    setState(() {
      widget.challenge.load();
    });
  }

  @override
  Widget build(BuildContext context) {
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
              colors: [Colors.white.withAlpha(10), Colors.white.withAlpha(205)],
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
              Text(
                widget.challenge.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              Text(
                widget.challenge.description,
                style: TextStyle(fontWeight: FontWeight.normal),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: LinearProgressIndicator(
                  value: widget.challenge.percent,
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
