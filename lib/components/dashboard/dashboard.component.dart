import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:wandr/components/about/about.component.dart';
import 'package:wandr/components/challenge/challenge.component.dart';
import 'package:wandr/components/dashboard/dashboard.item.challenge.dart';
import 'package:wandr/components/dashboard/dashboard.item.footer.dart';
import 'package:wandr/components/dashboard/dashboard.item.info.dart';
import 'package:wandr/components/dashboard/dashboard.item.ranking.dart';
import 'package:wandr/components/dashboard/dashboard.item.goal.dart';
import 'package:wandr/components/dashboard/dashboard.item.sync.dart';
import 'package:wandr/components/dashboard/dashboard.item.title.dart';
import 'package:wandr/components/history/history.component.add.dart';
import 'package:wandr/components/history/history.component.dart';
import 'package:wandr/components/landing/landing.component.dart';
import 'package:wandr/components/settings/settings.component.dart';
import 'package:wandr/components/teams/teams.component.dart';
import 'package:wandr/components/shared/bezier.clipper.dart';
import 'package:wandr/components/shared/localizer.dart';
import 'package:wandr/components/shared/route.transition.dart';
import 'package:wandr/model/fit.challenge.dart';
import 'package:wandr/model/fit.ranking.dart';
import 'package:wandr/model/fit.snapshot.dart';
import 'package:wandr/model/preferences.dart';
import 'package:wandr/model/repositories/challenge.repository.dart';
import 'package:wandr/model/repositories/repository.dart';
import 'package:wandr/model/storage.dart';

abstract class DashboardSyncDelegate {
  void onFitnessDataUpdate(FitSnapshot snapshot);

  List<FitChallenge> getChallenges();

  void onSettingsRequested();
}

class DashboardComponent extends StatefulWidget {
  ///
  final String title;

  ///
  DashboardComponent({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<DashboardComponent>
    implements
        DashboardTitleDelegate,
        DashboardSyncDelegate,
        DashboardInfoItemDelegate,
        DashboardChallengeDelegate,
        ChallengeRepositoryClient {
  ///
  String? _userName;

  ///
  String? _teamName;

  ///
  FitSnapshot? _fitSnapshot;

  ///
  bool _unitKilometersEnabled = false;

  ///
  FitRanking? _ranking;

  ///
  StreamSubscription? _rankingSubscription;

  ///
  List<FitChallenge> _challenges = [];

  ///
  final GlobalKey<DashboardSyncItemState> _syncKey =
      GlobalKey<DashboardSyncItemState>(debugLabel: 'DashboardSyncItemState');

  ///
  final GlobalKey<DashboardGoalItemState> _goalKey =
      GlobalKey<DashboardGoalItemState>(debugLabel: 'DashboardGoalItemState');

  ///
  final GlobalKey<DashboardRankingItemState> _rankingKey =
      GlobalKey<DashboardRankingItemState>(
          debugLabel: 'DashboardRankingItemState');

  @override
  void initState() {
    super.initState();

    _unitKilometersEnabled = false;
    ChallengeRepository().fetchChallenges(client: this);

    Preferences.getUserKey().then((userValue) {
      if (!mounted) return;

      if (userValue?.isNotEmpty == true) {
        setState(() {
          _userName = userValue!.split('@').first.replaceAll('.', '_');
          print('Init data for kUser=$_userName');
          _userName = _md5(_userName!);
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
      print('Kilometer unit enabled: $_unitKilometersEnabled');
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

  void _onSnapshotChanged(DatabaseEvent snapshot) {
    if (!mounted) return;
    setState(() {
      // create ranking from Firebase realtime database
      _ranking = FitRanking.createFromSnapshot(snapshot);
    });
  }

  @override
  void onFitnessDataUpdate(FitSnapshot snapshot) {
    if (!mounted) return;
    (_goalKey.currentState)?.reload(snapshot);
    setState(() {
      // apply local data snapshot with updated fitnes metrics from Google Fit or Apple health (or manually recorded data)
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
        page: SettingsComponent(userKey: _userName),
      ),
    ).then((_) async {
      (_syncKey.currentState)?.reload();
      (_rankingKey.currentState)?.reload(
          await Preferences().isFlagSet(kFlagUnitKilometers),
          await Preferences().getDifficultyLevel());
    });
  }

  @override
  void onTeamsRequested() {
    Navigator.push(
      context,
      RouteTransition(
        page: TeamsComponent(userKey: _userName),
      ),
    ).then((_) async {
      (_syncKey.currentState)?.reload();
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
  List<FitChallenge> getChallenges() {
    return this._challenges;
  }

  @override
  void challengeRepositoryDidUpdate(
    ChallengeRepository repository, {
    required SyncState state,
    required List<FitChallenge> challengeList,
  }) {
    if (!mounted || challengeList.isEmpty) return;
    _challenges.clear();
    setState(() {
      _challenges.addAll(challengeList);
    });
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
      itemCount: 7,
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
              child: DashboardGoalItem(
                key: _goalKey,
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
            return DashboardSyncItem(
              key: _syncKey,
              title: Localizer.translate(context, 'lblDashboardUserStats'),
              delegate: this,
              userKey: _userName,
              teamName: _teamName,
            );
          case 4:
            return DashboardChallengeItem(
              title:
                  Localizer.translate(context, 'lblDashboardActiveChallenges'),
              ranking: _ranking,
              snapshot: _fitSnapshot,
              userKey: _userName,
              teamName: _teamName,
              delegate: this,
            );
          case 5:
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
