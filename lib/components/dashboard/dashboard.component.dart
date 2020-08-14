import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:steps/components/dashboard/dashboard.item.challenge.dart';
import 'package:steps/components/dashboard/dashboard.item.ranking.dart';
import 'package:steps/components/dashboard/dashboard.item.sync.dart';
import 'package:steps/model/fit.ranking.dart';
import 'package:steps/model/storage.dart';

class Dashboard extends StatefulWidget {
  ///
  final String title;

  ///
  Dashboard({Key key, this.title}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  ///
  String _userKey;

  ///
  String _teamName;

  ///
  FitRanking _ranking;

  @override
  void initState() {
    super.initState();

    _userKey =
        'martin.kade@mediabeam.com'.split('@').first?.replaceAll('.', '_');
    _teamName = 'Team Martin';

    load();
  }

  void load() {
    Storage().access().then((instance) {
      final FirebaseDatabase db = FirebaseDatabase(app: instance);
      db.reference().child('users').once().then((snapshot) {
        if (!mounted) return;
        setState(() {
          _ranking = FitRanking.createFromSnapshot(snapshot);
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final Widget listWidget = ListView.builder(
      itemCount: 3,
      itemBuilder: (context, index) {
        switch (index) {
          case 0:
            return DashboardSyncItem(
              title: 'Deine Woche',
              userKey: _userKey,
              teamName: _teamName,
            );
          case 1:
            return DashboardChallengeItem(
              title: 'Aktuelle Challenge',
              ranking: _ranking,
              userKey: _userKey,
              teamName: _teamName,
            );
          default:
            return DashboardRankingItem(
              title: 'Team der Woche',
              ranking: _ranking,
              userKey: _userKey,
              teamName: _teamName,
            );
        }
      },
    );

    return Scaffold(
      // appBar: AppBar(
      //   title: Text(widget.title),
      // ),
      body: listWidget,
    );
  }
}
