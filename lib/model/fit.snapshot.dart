class FitSnapshot {
  ///
  final Map<dynamic, dynamic> data;

  ///
  FitSnapshot({this.data});

  ///
  Map<String, num> persist() {
    return Map.fromEntries(
      [
        MapEntry('today', today()),
        MapEntry('week', week()),
        MapEntry('lastWeek', lastWeek()),
        MapEntry('total', total()),
      ],
    );
  }

  ///
  num today() {
    return data['activeMinutes']['today'];
  }

  ///
  num week() {
    return data['activeMinutes']['week'];
  }

  ///
  num lastWeek() {
    return data['activeMinutes']['lastWeek'];
  }

  ///
  num total() {
    return data['activeMinutes']['total'];
  }
}
