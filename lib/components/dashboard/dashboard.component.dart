import 'dart:async';
import 'dart:convert';
import 'package:another_flushbar/flushbar.dart';
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
import 'package:wandr/components/purchases/purchases.component.dart';
import 'package:wandr/model/fit.challenge.dart';
import 'package:wandr/model/fit.ranking.dart';
import 'package:wandr/model/fit.snapshot.dart';
import 'package:wandr/model/fit.team.dart';
import 'package:wandr/model/preferences.dart';
import 'package:wandr/model/repositories/challenge.repository.dart';
import 'package:wandr/model/repositories/fitness.repository.dart';
import 'package:wandr/model/repositories/repository.dart';
import 'package:wandr/model/storage.dart';

abstract class DashboardSyncDelegate {
  void onFitnessDataUpdate(
    FitSnapshot snapshot, {
    required SyncState syncState,
  });

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
  String? _username;

  ///
  String? _teamName;

  ///
  String? _organizationName;

  ///
  FitSnapshot? _fitSnapshot;

  ///
  bool _unitKilometersEnabled = false;

  ///
  FitRanking? _ranking;

  ///
  StreamSubscription? _firebaseRealtimeDatabaseSubscription;

  ///
  List<FitChallenge> _challenges = [];

  ///
  final FitnessRepository _repository = FitnessRepository();

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

    Preferences.getUserKey().then((userValue) async {
      if (!mounted) return;

      final FitTeam? team = await Preferences.getTeam();
      final String? username = userValue['username'];
      final String? xworksToken = userValue['xworksToken'];
      if (username?.isNotEmpty == true && xworksToken?.isNotEmpty == true) {
        setState(() {
          _username = username?.split('@').first.replaceAll('.', '_');
          _username = _md5(_username!);
          _organizationName = 'Team mediaBEAM';
          _teamName = team == null ? 'Ohne Team' : team.name;
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

  void _load() async {
    _unitKilometersEnabled = await Preferences().isFlagSet(kFlagUnitKilometers);
    print('Kilometer unit enabled: $_unitKilometersEnabled');
    try {
      final firebaseApp = await Storage().access();
      if (firebaseApp == null) {
        throw Exception('Could not establish Firebase connection');
      }
      final FirebaseDatabase db =
          FirebaseDatabase.instanceFor(app: firebaseApp);
      await _fetchFirebaseRealtimeDatabaseSnapshot(db);
      _subscribeForFirebaseRealtimeUpdatesIfNeccessary(db);
    } on Exception catch (ex) {
      print('$ex');
    }
  }

  void _subscribeForFirebaseRealtimeUpdatesIfNeccessary(FirebaseDatabase db) {
    if (_firebaseRealtimeDatabaseSubscription != null) return;
    _firebaseRealtimeDatabaseSubscription =
        db.ref().child('users').onChildChanged.listen((childEvent) async {
      final dynamic snapshotKey = childEvent.snapshot.key;
      final dynamic snapshot = childEvent.snapshot.value;
      final String? displayName = snapshot?['meta']?['displayName'];
      if (displayName != null && snapshotKey != _username) {
        await Flushbar(
          title: 'WANDR News',
          message: Localizer.translate(context, 'lblDashboardUpdateDataMessage')
              .replaceFirst(
            '%1',
            displayName,
          ),
          duration: Duration(seconds: 3),
        ).show(context);
      }
      await _fetchFirebaseRealtimeDatabaseSnapshot(db);
    });
  }

  Future<void> _fetchFirebaseRealtimeDatabaseSnapshot(
      FirebaseDatabase db) async {
    try {
      final DatabaseEvent databaseEvent = await db.ref().child('users').once();
      _onFirebaseRealtimeDatabaseSnapshotUpdate(databaseEvent);
    } on Exception catch (ex) {
      print('$ex');
    }
  }

  void _onFirebaseRealtimeDatabaseSnapshotUpdate(DatabaseEvent snapshot) async {
    if (!mounted) return;
    final FitRanking ranking =
        await FitRanking.createFromFirebaseSnapshot(snapshot);
    if (ranking.obsoleteUserIdList.isNotEmpty) {
      await _repository.deleteObsoleteUserList(ranking.obsoleteUserIdList);
    }
    setState(() {
      _ranking = ranking;
    });
  }

  @override
  void onFitnessDataUpdate(
    FitSnapshot snapshot, {
    required SyncState syncState,
  }) {
    if (!mounted) return;
    (_goalKey.currentState)?.reload(snapshot);
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
        page: SettingsComponent(userKey: _username),
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
        page: TeamsComponent(userKey: _username),
      ),
    ).then((_) async {
      (_syncKey.currentState)?.reload();
    });
  }

  @override
  void onPurchasesRequested() {
    Navigator.push(
      context,
      RouteTransition(
        page: PurchasesComponent(userKey: _username),
      ),
    );
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
    _firebaseRealtimeDatabaseSubscription?.cancel();
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
                userKey: _username,
                teamName: _teamName,
                organizationName: _organizationName,
              ),
            );
          case 2:
            return DashboardSyncItem(
              key: _syncKey,
              title: Localizer.translate(context, 'lblDashboardUserStats'),
              repository: _repository,
              delegate: this,
              userKey: _username,
              teamName: _teamName,
              organizationName: _organizationName,
            );
          case 3:
            return DashboardInfoItem(
              delegate: this,
            );
          case 4:
            return DashboardChallengeItem(
              title:
                  Localizer.translate(context, 'lblDashboardActiveChallenges'),
              ranking: _ranking,
              snapshot: _fitSnapshot,
              userKey: _username,
              teamName: _teamName,
              organizationName: _organizationName,
              delegate: this,
            );
          case 5:
            return DashboardRankingItem(
              key: _rankingKey,
              title: Localizer.translate(context, 'lblDashboardTeamStandings'),
              ranking: _ranking,
              userKey: _username,
              teamName: _teamName,
              organizationName: _organizationName,
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
        child: _username == null || _teamName == null
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
