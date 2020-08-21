import 'package:flutter/material.dart';
import 'package:steps/components/shared/progress.text.animated.dart';
import 'package:steps/model/fit.challenge.dart';

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
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width - 32.0;
    final double height = width * 0.67;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                                child: Icon(
                                  Icons.arrow_back,
                                  size: 32.0,
                                ),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
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
                  padding: const EdgeInsets.fromLTRB(14.0, 8.0, 14.0, 0.0),
                  child: Text(
                    widget.challenge.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14.0, 8.0, 14.0, 32.0),
                  child: Text(
                    widget.challenge.description,
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14.0, 8.0, 14.0, 8.0),
                  child: AnimatedProgressText(
                    start: 0,
                    end: widget.challenge.progress.toInt(),
                    target: widget.challenge.target.toInt(),
                    fontSize: 48.0,
                    label: widget.challenge.label,
                  ),
                )
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          ),
        ),
      ),
    );
  }
}
