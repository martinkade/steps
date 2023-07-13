import 'dart:async';
import 'package:wandr/model/fit.challenge.dart';
import 'package:wandr/model/fit.challenge.team1.dart';
import 'package:wandr/model/fit.challenge.team2.dart';
import 'package:wandr/model/fit.challenge.team3.dart';
import 'package:wandr/model/fit.challenge.team4.dart';
import 'package:wandr/model/fit.challenge.team5.dart';
import 'package:wandr/model/fit.challenge.team6.dart';
import 'package:wandr/model/fit.challenge.team7.dart';
import 'package:wandr/model/fit.challenge.team8.dart';
import 'package:wandr/model/fit.challenge.team9.dart';
import 'package:wandr/model/repositories/repository.dart';

///
abstract class ChallengeRepositoryClient {
  void challengeRepositoryDidUpdate(
    ChallengeRepository repository, {
    required SyncState state,
    required List<FitChallenge> challengeList,
  });
}

class ChallengeRepository extends Repository {
  ///
  Future<List<FitChallenge>> fetchChallenges({
    required ChallengeRepositoryClient client,
  }) async {
    final List<FitChallenge> challengeList = <FitChallenge>[
      FitChallenge1Team(),
      FitChallenge2Team(),
      FitChallenge3Team(),
      FitChallenge4Team(),
      FitChallenge5Team(),
      FitChallenge6Team(),
      FitChallenge7Team(),
      FitChallenge8Team(),
      FitChallenge9Team()
    ];
    client.challengeRepositoryDidUpdate(
      this,
      state: SyncState.FETCHING_DATA,
      challengeList: challengeList,
    );
    // TODO: fetch data from server
    client.challengeRepositoryDidUpdate(
      this,
      state: SyncState.DATA_READY,
      challengeList: challengeList,
    );
    return challengeList;
  }
}
