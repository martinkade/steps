import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:steps/components/about/about.component.dart';
import 'package:steps/components/challenge/challenge.component.dart';
import 'package:steps/components/dashboard/dashboard.item.challenge.dart';
import 'package:steps/components/dashboard/dashboard.item.footer.dart';
import 'package:steps/components/dashboard/dashboard.item.info.dart';
import 'package:steps/components/dashboard/dashboard.item.ranking.dart';
import 'package:steps/components/dashboard/dashboard.item.sync.dart';
import 'package:steps/components/dashboard/dashboard.item.title.dart';
import 'package:steps/components/history/history.component.add.dart';
import 'package:steps/components/history/history.component.dart';
import 'package:steps/components/landing/landing.component.dart';
import 'package:steps/components/settings/settings.component.dart';
import 'package:steps/components/shared/bezier.clipper.dart';
import 'package:steps/components/shared/localizer.dart';
import 'package:steps/components/shared/route.transition.dart';
import 'package:steps/model/fit.challenge.dart';
import 'package:steps/model/fit.ranking.dart';
import 'package:steps/model/fit.snapshot.dart';
import 'package:steps/model/preferences.dart';
import 'package:steps/model/storage.dart';

class DashboardComponent extends StatefulWidget {
  ///
  final String title;

  ///
  DashboardComponent({Key key, this.title}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<DashboardComponent>
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
  bool _unitKilometersEnabled;

  ///
  FitRanking _ranking;

  ///
  StreamSubscription<Event> _rankingSubscription;

  ///
  final GlobalKey<DashboardSyncItemState> _syncKey =
      GlobalKey<DashboardSyncItemState>(
          debugLabel: '_DashboardSyncItemStateState');

  ///
  final GlobalKey<DashboardRankingItemState> _rankingKey =
      GlobalKey<DashboardRankingItemState>(
          debugLabel: '_DashboardRankingItemState');

  @override
  void initState() {
    super.initState();

    _unitKilometersEnabled = false;
    Preferences.getUserKey().then((userValue) {
      if (!mounted) return;

      if (userValue != null) {
        setState(() {
          _userName = userValue.split('@').first?.replaceAll('.', '_');
          print('Init data for kUser=$_userName');
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
      RouteTransition(page: Landing()),
    );
  }

  void _load() {
    Preferences().isFlagSet(kFlagUnitKilometers).then((enabled) {
      if (!mounted) return;
      _unitKilometersEnabled = enabled;
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
    });
  }

  void _onSnapshotChanged(DataSnapshot snapshot) {
    if (!mounted) return;
    setState(() {
      _ranking = FitRanking.createFromSnapshot(snapshot);
    });
  }

  @override
  void onFitnessDataUpdate(FitSnapshot snapshot) {
    if (!mounted) return;
    setState(() {
      _fitSnapshot = snapshot;
    });
  }

  @override
  void onHistoryRequested() {
    Navigator.push(
      context,
      RouteTransition(
        page: HistoryComponent(),
      ),
    ).then((_) {
      (_syncKey.currentState)?.reload();
    });
  }

  @override
  void onNewRecordRequested() {
    Navigator.push(
      context,
      RouteTransition(
        page: HistoryAdd(),
      ),
    ).then((_) {
      (_syncKey.currentState)?.reload();
    });
  }

  @override
  void onSettingsRequested() {
    Navigator.push(
      context,
      RouteTransition(
        page: SettingsComponent(),
      ),
    ).then((_) async {
      (_syncKey.currentState)?.reload();
      (_rankingKey.currentState)
          ?.reload(await Preferences().isFlagSet(kFlagUnitKilometers));
    });
  }

  @override
  void onInfoRequested() {
    Navigator.push(
      context,
      RouteTransition(
        page: About(),
      ),
    );
  }

  @override
  void onChallengeRequested(FitChallenge challenge, int index) {
    Navigator.push(
      context,
      RouteTransition(
        page: Challenge(
          challenge: challenge,
          index: index,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _rankingSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget listWidget = ListView.builder(
      physics: BouncingScrollPhysics(),
      itemCount: 6,
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
                key: _syncKey,
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
              key: _rankingKey,
              title: Localizer.translate(context, 'lblDashboardTeamStandings'),
              ranking: _ranking,
              userKey: _userName,
              teamName: _teamName,
            );
          default:
            return DashboardFooterItem(
              title: Localizer.translate(context, 'appName'),
            );
        }
      },
    );

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? Colors.yellow
          : Colors.black,
      body: SafeArea(
        child: _userName == null || _teamName == null
            ? Container(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Stack(
                  children: [
                    ClipPath(
                      clipper:
                          BezierClipper(leftHeight: 0.9, rightHeight: 0.67),
                      child: Container(
                        height: 256.0,
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.yellow
                            : Colors.black,
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
