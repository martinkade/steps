import 'package:flutter/material.dart';
import 'package:steps/components/shared/progress.text.animated.dart';
import 'package:steps/model/fit.challenge.dart';

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
  @override
  void initState() {
    super.initState();

    setState(() {
      widget.challenge.load();
    });
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
        )
      ],
    );
  }
}
