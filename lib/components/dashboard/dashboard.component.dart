import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:steps/components/dashboard/dashboard.item.challenge.dart';
import 'package:steps/components/dashboard/dashboard.item.ranking.dart';
import 'package:steps/components/dashboard/dashboard.item.sync.dart';
import 'package:steps/components/dashboard/dashboard.item.title.dart';
import 'package:steps/components/landing/landing.component.dart';
import 'package:steps/components/shared/bezier.clipper.dart';
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
  String _userName;

  ///
  String _teamName;

  ///
  FitRanking _ranking;

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((preferences) {
      final String userValue = preferences.getString('kUser');
      if (!mounted) return;

      if (userValue != null) {
        setState(() {
          _userName = userValue.split('@').first?.replaceAll('.', '_');
          _teamName = 'Die Entwickler dieser App 🤓';
        });

        _load();
      } else {
        _land();
      }
    });
  }

  void _land() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Landing()),
    );
  }

  void _load() {
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
      itemCount: 4,
      itemBuilder: (context, index) {
        switch (index) {
          case 0:
            return DashboardTitleItem(
              title: 'Die App',
            );
          case 1:
            return DashboardSyncItem(
              title: 'Deine Woche',
              userKey: _userName,
              teamName: _teamName,
            );
          case 2:
            return DashboardChallengeItem(
              title: 'Aktuelle Challenges',
              ranking: _ranking,
              userKey: _userName,
              teamName: _teamName,
            );
          case 3:
            return DashboardRankingItem(
              title: 'Team der Woche',
              ranking: _ranking,
              userKey: _userName,
              teamName: _teamName,
            );
          default:
            return Container();
        }
      },
    );

    return Scaffold(
      body: _userName == null || _teamName == null
          ? Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : Stack(
              children: [
                ClipPath(
                  clipper: BezierClipper(),
                  child: Container(
                    height: 192.0,
                    color: Color.fromARGB(255, 255, 215, 0),
                  ),
                ),
                listWidget
              ],
            ),
    );
  }
}
