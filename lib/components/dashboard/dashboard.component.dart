import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:steps/components/challenge/challenge.component.dart';
import 'package:steps/components/dashboard/dashboard.item.challenge.dart';
import 'package:steps/components/dashboard/dashboard.item.info.dart';
import 'package:steps/components/dashboard/dashboard.item.info.dialog.dart';
import 'package:steps/components/dashboard/dashboard.item.ranking.dart';
import 'package:steps/components/dashboard/dashboard.item.sync.dart';
import 'package:steps/components/dashboard/dashboard.item.title.dart';
import 'package:steps/components/history/history.component.add.dart';
import 'package:steps/components/history/history.component.dart';
import 'package:steps/components/landing/landing.component.dart';
import 'package:steps/components/settings/settings.component.dart';
import 'package:steps/components/shared/bezier.clipper.dart';
import 'package:steps/components/shared/localizer.dart';
import 'package:steps/model/fit.challenge.dart';
import 'package:steps/model/fit.ranking.dart';
import 'package:steps/model/fit.snapshot.dart';
import 'package:steps/model/storage.dart';

class Dashboard extends StatefulWidget {
  ///
  final String title;

  ///
  Dashboard({Key key, this.title}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    implements
        DashboardTitleDelegate,
        DashboardSyncDelegate,
        DashboardInfoItemDelegate,
        DashboardChallengeDelegate {
  ///
  String _userName;

  ///
  String _teamName;

  ///
  FitSnapshot _fitSnapshot;

  ///
  FitRanking _ranking;

  ///
  StreamSubscription<Event> _rankingSubscription;

  ///
  final key = GlobalKey();

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((preferences) {
      final String userValue = preferences.getString('kUser');
      if (!mounted) return;

      if (userValue != null) {
        setState(() {
          _userName = userValue.split('@').first?.replaceAll('.', '_');
          print('init data for kUser=$_userName');
          _userName = _md5(_userName);
          _teamName = 'Team mediaBEAM';
        });

        _load();
      } else {
        _land();
      }
    });
  }

  String _md5(String value) {
    return md5.convert(utf8.encode(value)).toString();
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
        _onSnapshotChanged(snapshot);
      });

      if (_rankingSubscription == null) {
        _rankingSubscription =
            db.reference().child('users').onChildChanged.listen((_) {
          if (!mounted) return;
          db.reference().child('users').once().then((snapshot) {
            _onSnapshotChanged(snapshot);
          });
        });
      }
    });
  }

  void _onSnapshotChanged(DataSnapshot snapshot) {
    if (snapshot == null) return;
    setState(() {
      _ranking = FitRanking.createFromSnapshot(snapshot);
    });
  }

  @override
  void onFitnessDataUpadte(FitSnapshot snapshot) {
    if (!mounted) return;
    setState(() {
      _fitSnapshot = snapshot;
    });
  }

  @override
  void onHistoryRequested() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => History(),
      ),
    ).then((_) {
      (key.currentState as DashboardSyncItemState)?.reload();
    });
  }

  @override
  void onNewRecordRequested() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HistoryAdd(),
      ),
    ).then((_) {
      (key.currentState as DashboardSyncItemState)?.reload();
    });
  }

  @override
  void onSettingsRequested() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Settings(),
      ),
    ).then((_) {
      (key.currentState as DashboardSyncItemState)?.reload();
    });
  }

  @override
  void onInfoRequested() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: DashboardInfoDialogContent(
              onDismiss: () {
                Navigator.of(context).pop();
              },
            ),
          );
        });
  }

  @override
  void onChallengeRequested(FitChallenge challenge, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Challenge(
          challenge: challenge,
          index: index,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _rankingSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget listWidget = ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        switch (index) {
          case 0:
            return DashboardTitleItem(
              title: Localizer.translate(context, 'appName'),
              delegate: this,
            );
          case 1:
            return GestureDetector(
              onTap: () {
                onHistoryRequested();
              },
              child: DashboardSyncItem(
                key: key,
                title: Localizer.translate(context, 'lblDashboardUserStats'),
                delegate: this,
                userKey: _userName,
                teamName: _teamName,
              ),
            );
          case 2:
            return DashboardInfoItem(
              delegate: this,
            );
          case 3:
            return DashboardChallengeItem(
              title:
                  Localizer.translate(context, 'lblDashboardActiveChallenges'),
              ranking: _ranking,
              snapshot: _fitSnapshot,
              userKey: _userName,
              teamName: _teamName,
              delegate: this,
            );
          case 4:
            return DashboardRankingItem(
              title: Localizer.translate(context, 'lblDashboardTeamStandings'),
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
      backgroundColor: Color.fromARGB(255, 255, 215, 0),
      body: SafeArea(
        child: _userName == null || _teamName == null
            ? Container(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : Container(
                color: Colors.white,
                child: Stack(
                  children: [
                    ClipPath(
                      clipper:
                          BezierClipper(leftHeight: 0.9, rightHeight: 0.67),
                      child: Container(
                        height: 256.0,
                        color: Color.fromARGB(255, 255, 215, 0),
                      ),
                    ),
                    listWidget
                  ],
                ),
              ),
      ),
    );
  }
}
