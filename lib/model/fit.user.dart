class FitUser {
  ///
  String id = '';

  ///
  String? name;

  ///
  String? team;

  ///
  String? organization;

  ///
  int? today;

  ///
  FitUser({String id = '', String? name}) {
    this.id = id;
    this.name = name;
  }

  ///
  void initWithCursor(Map<String, dynamic> cursor) {}

  ///
  void fill(
      {String id = '', String? name, String? team, String? organization, int? today}) {
    this.id = id;
    this.name = name;
    this.team = team;
    this.organization = organization;
    this.today = today;
  }

  ///
  String get idString => id;
}
