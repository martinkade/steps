import 'package:collection/collection.dart';
import 'package:wandr/__secrets.dart';
import 'package:wandr/components/settings/settings.item.difficulty.dart';
import 'package:wandr/model/fit.ranking.dart';
import 'package:wandr/util/ChatGPTRequestMessage.dart';
import 'package:wandr/util/Purchase.dart';

class AprilJokes {
  static String botID = BOT_ID;
  static String? botName;

  static List<Purchase> purchases = [
    Purchase("Tagesfüllung 100%", "Heute stehen viele Termine an? Das Bett ist gerade so bequem? Kein Problem! Für einen günstigen Preis kannst du dein Tagesziel erfüllen ohne vor die Tür zu müssen!", "1,99€", [
      ChatGPTRequestMessage("system", "WANDR ist eine App die Schritte aufzeichnet und so Nutzer zu täglicher Bewegung motivieren möchte. Du bist wütend weil ein Nutzer versucht mit Geld sein Tagesziel zu erfüllen ohne sich dafür bewegen zu müssen"),
      ChatGPTRequestMessage("user", "Der Nutzer versucht sein heutiges Bewegungsziel nicht erfüllen zu müssen indem er 1,99€ bezahlt um sein Tagesziel füllen zu lassen."),
      ChatGPTRequestMessage("system", "Falls der Nutzer einen Namen angibt sprich ihn bitte persönlich an und lasse ihn deinen Unmut spüren. Beende deine Antwort mit einem Witz.")
    ]),
    Purchase("Tagesfüllung 200%", "Der Rücken schmerzt und die Knochen machen im Alter auch nicht mehr so mit? Du möchtest noch einmal an der Tabellenspitze stehen, aber die jungen Leute heutzutage laufen alle so viel? Mit diesem Kauf werden 200% deines Tagesziels deiner heutigen Leistung hinzugefügt. Noch besser, sollte das nicht reichen lässt sich dieser Kauf auch stapeln!", "2,99€", [
      ChatGPTRequestMessage("system", "WANDR ist eine App die Schritte aufzeichnet und so Nutzer zu täglicher Bewegung motivieren möchte. Du bist sehr wütend weil ein Nutzer versucht mit Geld sein Tagesziel zu erfüllen ohne sich dafür bewegen zu müssen"),
      ChatGPTRequestMessage("user", "Der Nutzer versucht sein heutiges Bewegungsziel nicht erfüllen zu müssen indem er 2,99€ bezahlt um sein Tagesziel füllen zu lassen. Dabei gibt er sogar mehr Geld aus um eine besonders gute Leistung vorzutäuschen."),
      ChatGPTRequestMessage("system", "Falls der Nutzer einen Namen angibt sprich ihn bitte persönlich an und lasse ihn spüren das du sehr wütend bist. Erfinde neue Wörter und streue sie in deine Antwort mit ein."),
      ChatGPTRequestMessage("system", "Versuche Filmzitate in die Antwort mit einzubauen.")
    ]),
    Purchase("Wochenfüllung", "Du kennst es bestimmt, eigentlich hattest du dir vorgenommen jeden Tag laufen zu gehen und am Ende der Woche hat es doch nicht gereicht. Zu Wochenbeginn lästern die Kollegen dann wieder über deine klägliche Schrittleistung der letzten Woche. Mit diesem Kauf lässt sich das einfach umgehen. Für einen geringen Betrag ist garantiert das du dein Wochenziel erreichst. Alles was du dann noch selber läufst kommt als netter Bonus mit dazu.", "5,99€", [
      ChatGPTRequestMessage("system", "WANDR ist eine App die Schritte aufzeichnet und so Nutzer zu täglicher Bewegung motivieren möchte. Du bist extrem wütend weil ein Nutzer versucht mit Geld sein Wochenziel zu erfüllen um sich die ganze Woche nicht mehr bewegen zu müssen."),
      ChatGPTRequestMessage("user", "Der Nutzer versucht sein gesamtes Wochenziel nicht erfüllen zu müssen indem er 5,99€ bezahlt um sein Wochenziel füllen zu lassen. Damit betrügt er sich und seine Kollegen."),
      ChatGPTRequestMessage("system", "Falls der Nutzer einen Namen angibt sprich ihn bitte persönlich an und lasse ihn spüren das du extrem wütend bist. Streue ein paar erfundene lustige Namen mit ein mit denen du ihn bezeichnest.")
    ]),
    Purchase("Jahresabo", "Im Sommer ist es zu warm, im Winter zu kalt und dazwischen ist es auch nicht schön. Falls für dich der wöchentliche Einkauf schon genug Bewegung ist kannst du mit diesem Kauf direkt dafür sorgen das WANDR für dieses Jahr abgehakt ist. Ein Jahr lang wird zum Vorteilspreis jeden Tag dein Tagesziel erfüllt!", "120,99€", [
      ChatGPTRequestMessage("system", "WANDR ist eine App die Schritte aufzeichnet und so Nutzer zu täglicher Bewegung motivieren möchte. Du bist fassungslos weil ein Nutzer versucht mit Geld sein Tagesziel für ein Jahr zu erfüllen und sich damit über den Zeitraum nicht viel bewegen muss."),
      ChatGPTRequestMessage("user", "Der Nutzer versucht sein gesamtes Jahresziel nicht erfüllen zu müssen indem er 120,99€ bezahlt um sein Jahresziel füllen zu lassen. Damit betrügt er sich und seine Kollegen."),
      ChatGPTRequestMessage("system", "Falls der Nutzer einen Namen angibt sprich ihn bitte persönlich an und lasse ihn spüren das du fassungslos bist. Streue ein paar erfundene Flüche mit ein.")
    ])
  ];

  bool isJokeActive(Jokes joke) {
    if (DateTime.now().day != 1 || DateTime.now().month != DateTime.april) {
      return false;
    }

    switch (joke) {
      case Jokes.rankingLast:
        return DateTime.now().year % 3 == 0;
      case Jokes.botDifficulty:
        return DateTime.now().year % 3 == 1;
      case Jokes.purchases:
        return DateTime.now().year % 3 == 2;
    }
  }

  String getBotName() {
    if (AprilJokes.botName?.isNotEmpty == true) {
      return AprilJokes.botName!;
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
    final FitRankingEntry? me =
        list.firstWhereOrNull((element) => element.key == itemKey);
    final int extraValue = (me?.value ?? 0).toInt();
    list.sort((a, b) {
      if (a.key == itemKey) {
        return 1;
      }
      return a.value >= b.value ? -1 : 1;
    });
    return extraValue;
  }
}

enum Jokes { rankingLast, botDifficulty, purchases }
