import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:steps/model/cache/fit.dao.spec.dart';
import 'package:steps/model/cache/structured.cache.dart';
import 'package:steps/model/fit.record.dart';

class FitRecordDao extends FitDao {
  static const String TBL_NAME = 'tbl_fit_record';
  static const String COL_TIMESTAMP = '_timestamp';
  static const String COL_SOURCE = 'source';
  static const String COL_TYPE = 'type';
  static const String COL_VALUE = 'value';
  static const String COL_NAME = 'name';

  ///
  static const String CMD_CREATE_TABLE =
      'CREATE TABLE IF NOT EXISTS ${FitRecordDao.TBL_NAME} ('
      '${FitRecordDao.COL_TIMESTAMP} INTEGER PRIMARY KEY,'
      '${FitRecordDao.COL_SOURCE} INTEGER DEFAULT 0,'
      '${FitRecordDao.COL_TYPE} INTEGER DEFAULT 0,'
      '${FitRecordDao.COL_VALUE} INTEGER DEFAULT 0,'
      '${FitRecordDao.COL_NAME} TEXT'
      ')';

  ///
  static const String CMD_DROP_TABLE =
      'DROP TABLE IF EXISTS ${FitRecordDao.TBL_NAME}';

  ///
  static Future<void> create({@required Transaction txn}) async {
    await txn.execute(FitRecordDao.CMD_DROP_TABLE);
    await txn.execute(FitRecordDao.CMD_CREATE_TABLE);
  }

  ///
  static Future<void> upgrade(int fromVersion, int toVersion,
      {@required Transaction txn}) async {
    await txn.execute(FitRecordDao.CMD_DROP_TABLE);
    await txn.execute(FitRecordDao.CMD_CREATE_TABLE);
  }

  ///
  static Future<void> downgrade(int fromVersion, int toVersion,
      {@required Transaction txn}) async {
    await txn.execute(FitRecordDao.CMD_DROP_TABLE);
    await txn.execute(FitRecordDao.CMD_CREATE_TABLE);
  }

  ///
  Future<void> insertOrReplace({@required List<FitRecord> records}) async {
    final Database db = await StructuredCache().getDb();
    await db.transaction((txn) async {
      String statement;
      final Batch batch = txn.batch();
      records.forEach((record) {
        statement = buildStatement(
            'INSERT OR REPLACE INTO ${FitRecordDao.TBL_NAME} ' +
                '(${FitRecordDao.COL_TIMESTAMP}, ${FitRecordDao.COL_SOURCE}, ${FitRecordDao.COL_TYPE}, ${FitRecordDao.COL_VALUE}, ${FitRecordDao.COL_NAME}) VALUES ' +
                '(?, ?, ?, ?, ?)',
            [
              record.timestamp,
              record.source,
              record.type,
              record.value,
              record.name,
            ]);
        batch.rawInsert(statement);
      });
      await batch.commit(continueOnError: true);
    });
  }

  ///
  Future<void> delete(
      {@required List<FitRecord> records, bool exclude = false}) async {
    final String idList = records.map((it) => '${it.idString}').join(',');
    final Database db = await StructuredCache().getDb();
    await db.transaction((txn) async {
      txn.rawDelete('DELETE FROM ${FitRecordDao.TBL_NAME} ' +
          'WHERE ${FitRecordDao.COL_TIMESTAMP} ${exclude ? 'NOT IN' : 'IN'} ($idList)');
    });
  }

  ///
  Future<List<FitRecord>> fetch(
      {@required DateTime from, bool onlyManualRecords}) async {
    final Database db = await StructuredCache().getDb();
    final String statement = onlyManualRecords
        ? 'SELECT * FROM ${FitRecordDao.TBL_NAME} ' +
            'WHERE ${FitRecordDao.COL_TIMESTAMP} >= ${from.millisecondsSinceEpoch} AND ${FitRecordDao.COL_SOURCE} = ${FitRecord.SOURCE_MANUAL} ' +
            'ORDER BY ${FitRecordDao.COL_TIMESTAMP} DESC'
        : 'SELECT * FROM ${FitRecordDao.TBL_NAME} ' +
            'WHERE ${FitRecordDao.COL_TIMESTAMP} >= ${from.millisecondsSinceEpoch} ' +
            'ORDER BY ${FitRecordDao.COL_TIMESTAMP} DESC';
    final List<Map<String, dynamic>> result = await db.rawQuery(statement);
    FitRecord record;
    final List<FitRecord> records = List();
    for (Map<String, dynamic> cursor in result) {
      record = FitRecord();
      record.initWithCursor(cursor);
      records.add(record);
    }
    return records;
  }

  ///
  Future<List<FitRecord>> fetchAll({DateTime from}) async {
    final Database db = await StructuredCache().getDb();
    final List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT * FROM ${FitRecordDao.TBL_NAME} ' +
            'WHERE ${FitRecordDao.COL_TIMESTAMP} >= ${from?.millisecondsSinceEpoch ?? 0} ' +
            'ORDER BY ${FitRecordDao.COL_TIMESTAMP} DESC');
    FitRecord record;
    final List<FitRecord> records = List();
    for (Map<String, dynamic> cursor in result) {
      record = FitRecord();
      record.initWithCursor(cursor);
      records.add(record);
    }
    return records;
  }

  ///
  Future<List<FitRecord>> fetchAllByDayAndPoints(
      {DateTime from, DateTime to}) async {
    final Database db = await StructuredCache().getDb();
    final List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT *, date(${FitRecordDao.COL_TIMESTAMP} / 1000, \'unixepoch\', \'localtime\') AS _day, ' +
            'SUM(CASE ${FitRecordDao.COL_TYPE} WHEN ${FitRecord.TYPE_STEPS} THEN ${FitRecordDao.COL_VALUE} / 80 ELSE ${FitRecordDao.COL_VALUE} END) AS _sum, ' +
            'COUNT(${FitRecordDao.COL_TIMESTAMP}) AS _count FROM ${FitRecordDao.TBL_NAME} ' +
            'WHERE ${FitRecordDao.COL_TIMESTAMP} >= ${from?.millisecondsSinceEpoch ?? 0} ' +
            'AND ${FitRecordDao.COL_TIMESTAMP} < ${to?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch} ' +
            'GROUP BY _day ' +
            'ORDER BY ${FitRecordDao.COL_TIMESTAMP} DESC');
    FitRecord record;
    final List<FitRecord> records = List();
    for (Map<String, dynamic> cursor in result) {
      record = FitRecord();
      record.initWithCursor(cursor);
      record.value = cursor['_sum'];
      record.count = cursor['_count'];
      records.add(record);
    }
    return records;
  }

  ///
  Future<List<FitRecord>> fetchAllOfDay({String day}) async {
    final Database db = await StructuredCache().getDb();
    final List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT *, date(${FitRecordDao.COL_TIMESTAMP} / 1000, \'unixepoch\', \'localtime\') AS _day FROM ${FitRecordDao.TBL_NAME} ' +
            'WHERE _day = \'$day\' ' +
            'ORDER BY ${FitRecordDao.COL_TIMESTAMP} DESC');
    FitRecord record;
    final List<FitRecord> records = List();
    for (Map<String, dynamic> cursor in result) {
      record = FitRecord();
      record.initWithCursor(cursor);
      records.add(record);
    }
    return records;
  }
}
