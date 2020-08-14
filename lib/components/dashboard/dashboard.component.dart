import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:steps/components/dashboard/dashboard.item.challenge.dart';
import 'package:steps/components/dashboard/dashboard.item.ranking.dart';
import 'package:steps/components/dashboard/dashboard.item.sync.dart';
import 'package:steps/components/dashboard/dashboard.item.title.dart';
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
    _teamName = 'Team A';

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
              userKey: _userKey,
              teamName: _teamName,
            );
          case 2:
            return DashboardChallengeItem(
              title: 'Aktuelle Challenges',
              ranking: _ranking,
              userKey: _userKey,
              teamName: _teamName,
            );
          case 3:
            return DashboardRankingItem(
              title: 'Team der Woche',
              ranking: _ranking,
              userKey: _userKey,
              teamName: _teamName,
            );
          default:
            return Container();
        }
      },
    );

    return Scaffold(
      body: Stack(
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

class BezierClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = new Path();
    path.lineTo(0.0, size.height * 0.75);
    path.quadraticBezierTo(
        size.width * 0.5, size.height, size.width, size.height * 0.75);
    path.lineTo(size.width, 0.0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
