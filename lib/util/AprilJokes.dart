import 'package:collection/collection.dart';
import 'package:wandr/__secrets.dart';
import 'package:wandr/components/settings/settings.item.difficulty.dart';
import 'package:wandr/model/fit.ranking.dart';

class AprilJokes {
  static String botID = BOT_ID;
  static String botName;

  bool isJokeActive(Jokes joke) {
    if (DateTime.now().day != 1 || DateTime.now().month == DateTime.april) {
      return false;
    }

    switch (joke) {
      case Jokes.rankingLast:
        return DateTime.now().year % 2 == 0;
      case Jokes.botDifficulty:
        return DateTime.now().year % 2 == 1;
    }
    return false;
  }

  String getBotName() {
    if (AprilJokes.botName != null && AprilJokes.botName.isNotEmpty) {
      return AprilJokes.botName;
    }
    return "Anonymer Bot";
  }

  updateList(List<FitRankingEntry> list, int difficultyLevel) {
    Difficulties difficulty = Difficulties.values[difficultyLevel];
    double multiplicator = 1.0;
    switch (difficulty) {
      case Difficulties.easy:
        multiplicator = 0.5;
        break;
      case Difficulties.normal:
        multiplicator = 0.75;
        break;
      case Difficulties.hard:
        multiplicator = 1.0;
        break;
      case Difficulties.veryHard:
        multiplicator = 1.5;
        break;
    }
    for (FitRankingEntry entry in list) {
      if (entry.key == AprilJokes.botID) {
        entry.value = (entry.value * multiplicator).round();
        break;
      }
    }
    list.sort((b, a) => a.value.compareTo(b.value));
  }

  int getRankingLastExtraValue(List<FitRankingEntry> list, String itemKey) {
    final FitRankingEntry me =
        list.firstWhereOrNull((element) => element.key == itemKey);
    final int extraValue = me?.value ?? 0;
    list.sort((a, b) {
      if (a.key == itemKey) {
        return 1;
      }
      return a.value >= b.value ? -1 : 1;
    });
    return extraValue;
  }
}

enum Jokes { rankingLast, botDifficulty }
