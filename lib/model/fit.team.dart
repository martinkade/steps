import 'package:wandr/model/cache/fit.record.dao.dart';
import 'package:wandr/model/cache/fit.team.dao.dart';
import 'package:uuid/uuid.dart';

class FitTeam {
  ///
  String uuid = '';

  ///
  String? name;

  ///
  FitTeam({String uuid = '', String? name}) {
    this.uuid = uuid.isEmpty ? Uuid().v4() : uuid;
    this.name = name;
  }

  ///
  void initWithCursor(Map<String, dynamic> cursor) {
    uuid = cursor[FitTeamDao.COL_UUID];
    name = cursor[FitRecordDao.COL_NAME];
  }

  ///
  void fill({String uuid = '', String? name}) {
    this.uuid = uuid.isEmpty ? Uuid().v4() : uuid;
    this.name = name;
  }

  ///
  String get idString => uuid;
}
