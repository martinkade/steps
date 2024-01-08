import 'package:sqflite/sqflite.dart';
import 'package:wandr/model/cache/fit.dao.spec.dart';
import 'package:wandr/model/cache/structured.cache.dart';
import 'package:wandr/model/fit.team.dart';

class FitTeamDao extends FitDao {
  static const String TBL_NAME = 'tbl_fit_team';
  static const String COL_UUID = '_uuid';
  static const String COL_NAME = 'name';

  ///
  static const String CMD_CREATE_TABLE =
      'CREATE TABLE IF NOT EXISTS ${FitTeamDao.TBL_NAME} ('
      '${FitTeamDao.COL_UUID} TEXT PRIMARY KEY,'
      '${FitTeamDao.COL_NAME} TEXT'
      ')';

  ///
  static const String CMD_DROP_TABLE =
      'DROP TABLE IF EXISTS ${FitTeamDao.TBL_NAME}';

  ///
  static Future<void> create({required Transaction txn}) async {
    await txn.execute(FitTeamDao.CMD_DROP_TABLE);
    await txn.execute(FitTeamDao.CMD_CREATE_TABLE);
  }

  ///
  static Future<void> upgrade(int fromVersion, int toVersion,
      {required Transaction txn}) async {
    await txn.execute(FitTeamDao.CMD_DROP_TABLE);
    await txn.execute(FitTeamDao.CMD_CREATE_TABLE);
  }

  ///
  static Future<void> downgrade(int fromVersion, int toVersion,
      {required Transaction txn}) async {
    await txn.execute(FitTeamDao.CMD_DROP_TABLE);
    await txn.execute(FitTeamDao.CMD_CREATE_TABLE);
  }

  ///
  Future<void> insertOrReplace({required List<FitTeam> teams}) async {
    final Database db = await StructuredCache().getDb();
    await db.transaction((txn) async {
      String statement;
      final Batch batch = txn.batch();
      teams.forEach((record) {
        statement = buildStatement(
            'INSERT OR REPLACE INTO ${FitTeamDao.TBL_NAME} ' +
                '(${FitTeamDao.COL_UUID}, ${FitTeamDao.COL_NAME}) VALUES ' +
                '(?, ?)',
            [
              record.uuid,
              record.name,
            ]);
        batch.rawInsert(statement);
      });
      await batch.commit(continueOnError: true);
    });
  }

  ///
  Future<void> delete({
    required List<FitTeam> teams,
    bool exclude = false,
  }) async {
    final String idList = teams.map((it) => '\'${it.idString}\'').join(',');
    final Database db = await StructuredCache().getDb();
    await db.transaction((txn) async {
      txn.rawDelete('DELETE FROM ${FitTeamDao.TBL_NAME} ' +
          'WHERE ${FitTeamDao.COL_UUID} ${exclude ? 'NOT IN' : 'IN'} ($idList)');
    });
  }

  ///
  Future<FitTeam?> fetch({required String uuid}) async {
    final Database db = await StructuredCache().getDb();
    final String statement = 'SELECT * FROM ${FitTeamDao.TBL_NAME} ' +
        'WHERE ${FitTeamDao.COL_UUID} = \'$uuid\'';
    final List<Map<String, dynamic>> result = await db.rawQuery(statement);
    FitTeam? team;
    for (Map<String, dynamic> cursor in result) {
      team = FitTeam();
      team.initWithCursor(cursor);
    }
    return team;
  }

  ///
  Future<List<FitTeam>> fetchAll() async {
    final Database db = await StructuredCache().getDb();
    final List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT * FROM ${FitTeamDao.TBL_NAME} ' +
            'ORDER BY ${FitTeamDao.COL_NAME} ASC');
    FitTeam team;
    final List<FitTeam> teams = <FitTeam>[];
    for (Map<String, dynamic> cursor in result) {
      team = FitTeam();
      team.initWithCursor(cursor);
      teams.add(team);
    }
    return teams;
  }
}
