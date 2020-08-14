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

  @override
  void initState() {
    super.initState();
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
      padding: const EdgeInsets.fromLTRB(18.0, 22.0, 20, 8.0),
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Schade :(',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20.0),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Die App kann nicht auf die Daten aus Google Fit bzw. Apple Health zugreifen.',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        titleWidget,
        Card(
          elevation: 2.0,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: widget.ranking == null ? loadingWidget : contentWidget,
        )
      ],
    );
  }
}
