import 'dart:math';

import 'package:flutter/material.dart';
import 'package:steps/components/dashboard/dashboard.item.challenge.detail.dart';
import 'package:steps/components/dashboard/dashboard.item.dart';
import 'package:steps/model/fit.challenge.dart';
import 'package:steps/model/fit.challenge.team.dart';
import 'package:steps/model/fit.challenge.week.dart';
import 'package:steps/model/fit.ranking.dart';
import 'package:steps/model/fit.snapshot.dart';

abstract class DashboardChallengeDelegate {
  void onChallengeRequested(FitChallenge challenge, int index);
}

class DashboardChallengeItem extends DashboardItem {
  ///
  final String userKey;

  ///
  final String teamName;

  ///
  final FitRanking ranking;

  ///
  final FitSnapshot snapshot;

  ///
  final DashboardChallengeDelegate delegate;

  ///
  DashboardChallengeItem({
    Key key,
    String title,
    this.ranking,
    this.snapshot,
    this.userKey,
    this.teamName,
    this.delegate,
  }) : super(key: key, title: title);

  @override
  _DashboardChallengeItemState createState() => _DashboardChallengeItemState();
}

class _DashboardChallengeItemState extends State<DashboardChallengeItem> {
  ///
  ScrollController _scrollController;

  ///
  List<FitChallenge> _challenges;

  ///
  int _cardIndex = 0;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _challenges = [
      FitChallengeTeam(context),
      FitChallengeWeek(context),
    ];
  }

  @override
  void didUpdateWidget(DashboardChallengeItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    _challenges.forEach((challenge) {
      challenge.load(snapshot: widget.snapshot, ranking: widget.ranking);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double cardWidth =
        min(MediaQuery.of(context).size.width - 24.0, 312.0);
    final double cardHeight = max(cardWidth * 0.75, 256.0);

    final Widget loadingWidget = Container(
      child: Center(
        child: CircularProgressIndicator(),
      ),
      height: cardHeight + 16.0,
    );

    final Widget titleWidget = Padding(
      padding: const EdgeInsets.fromLTRB(22.0, 22.0, 22.0, 4.0),
      child: Text(
        widget.title,
        style: TextStyle(
          fontSize: 16.0,
          color: Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    final Widget contentWidget = Container(
      height: cardHeight + 16.0,
      child: ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        itemCount: _challenges?.length ?? 0,
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(0.0),
        itemBuilder: (context, index) {
          final FitChallenge challenge = _challenges[index];
          return GestureDetector(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                  8.0, 0.0, index < _challenges.length - 1 ? 0.0 : 8.0, 8.0),
              child: Hero(
                child: Card(
                  elevation: 8.0,
                  shadowColor: Colors.grey.withAlpha(50),
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Container(
                    height: cardHeight,
                    width: cardWidth,
                    child: DashboardChallengeDetail(
                      challenge: challenge,
                      index: index,
                    ),
                  ),
                ),
                tag: 'challenge-$index',
              ),
            ),
            onHorizontalDragEnd: (details) {
              if (details.velocity.pixelsPerSecond.dx > 0) {
                if (_cardIndex > 0) _cardIndex--;
              } else {
                if (_cardIndex < 2) _cardIndex++;
              }
              setState(() {
                _scrollController.animateTo(
                  _cardIndex * cardWidth + _cardIndex * 16.0,
                  duration: Duration(milliseconds: 200),
                  curve: Curves.fastOutSlowIn,
                );
              });
            },
            onTap: () {
              widget.delegate?.onChallengeRequested(challenge, index);
            },
          );
        },
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        titleWidget,
        widget.ranking == null
            ? Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
                child: Card(
                  elevation: 8.0,
                  shadowColor: Colors.grey.withAlpha(50),
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: loadingWidget,
                ),
              )
            : contentWidget
      ],
    );
  }
}
