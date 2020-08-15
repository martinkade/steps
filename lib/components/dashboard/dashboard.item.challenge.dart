import 'package:flutter/material.dart';
import 'package:steps/components/dashboard/dashboard.item.dart';
import 'package:steps/model/fit.ranking.dart';

class DashboardChallengeItem extends DashboardItem {
  ///
  final String userKey;

  ///
  final String teamName;

  ///
  final FitRanking ranking;

  ///
  DashboardChallengeItem(
      {Key key, String title, this.ranking, this.userKey, this.teamName})
      : super(key: key, title: title);

  @override
  _DashboardChallengeItemState createState() => _DashboardChallengeItemState();
}

class _DashboardChallengeItemState extends State<DashboardChallengeItem> {
  ///
  bool _loading = true;

  ///
  ScrollController _scrollController;

  ///
  int _cardIndex = 0;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget loadingWidget = Container(
      child: Center(
        child: CircularProgressIndicator(),
      ),
      height: 96.0,
    );

    final Widget titleWidget = Padding(
      padding: const EdgeInsets.fromLTRB(18.0, 22.0, 20, 4.0),
      child: Text(
        widget.title,
        style: TextStyle(
          fontSize: 16.0,
          color: Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    final double cardWidth = 312.0;
    final double cardHeight = cardWidth * 0.75;
    final Widget contentWidget = Container(
      height: cardHeight + 16.0,
      child: ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        itemCount: 3,
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(0.0),
        itemBuilder: (context, index) {
          return GestureDetector(
            child: Padding(
              padding:
                  EdgeInsets.fromLTRB(8.0, 0.0, index < 2 ? 0.0 : 8.0, 8.0),
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
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                                'assets/images/challenge${index + 1}.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                          colors: [
                            Colors.white.withAlpha(10),
                            Colors.white.withAlpha(205)
                          ],
                          stops: [0.1, 0.9],
                          begin: Alignment.topRight,
                          end: Alignment.bottomCenter,
                        )),
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
                              '${index + 1} mal um die Welt',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                            ),
                            Text(
                              'Beschreibung der Challenge',
                              style: TextStyle(fontWeight: FontWeight.normal),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: LinearProgressIndicator(
                                value: ((index + 1) * 13.0) * 0.01,
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
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
          );
        },
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
