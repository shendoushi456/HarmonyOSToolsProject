// 测速历史库 - 对齐 Android wifimeter/DataBase/MyDatabaseHelper.java
// 库 HSLibrary.db 表 my_HS(hs_time/hs_type/hs_ping/hs_download/hs_upload 均为含单位文本)
import 'package:sqflite/sqflite.dart';

class SpeedHistoryDb {
  SpeedHistoryDb._();
  static final SpeedHistoryDb instance = SpeedHistoryDb._();

  Database? _db;

  static const String _dbName = 'HSLibrary.db';
  static const int _dbVersion = 1;
  static const String tableHs = 'my_HS';
  static const String colId = '_id';
  static const String colTime = 'hs_time';
  static const String colType = 'hs_type';
  static const String colPing = 'hs_ping';
  static const String colDownload = 'hs_download';
  static const String colUpload = 'hs_upload';

  Future<Database> _open() async {
    if (_db != null && _db!.isOpen) return _db!;
    final path = await getDatabasesPath();
    _db = await openDatabase('$path/$_dbName', version: _dbVersion,
        onCreate: (db, version) async {
      // 对齐 MyDatabaseHelper.onCreate 建表 SQL
      await db.execute('''
        create table $tableHs(
          $colId integer primary key autoincrement,
          $colTime text,
          $colType text,
          $colPing text,
          $colDownload text,
          $colUpload text)
      ''');
    });
    return _db!;
  }

  /// 写入一条历史(对齐 addBook,返回是否成功供 Toast 判断)
  Future<bool> addHistory(
      String time, String type, String ping, String download, String upload) async {
    final db = await _open();
    final result = await db.insert(tableHs, {
      colTime: time,
      colType: type,
      colPing: ping,
      colDownload: download,
      colUpload: upload,
    });
    return result != -1;
  }

  /// 读取全部历史(对齐 readAllData,保真无页面入口)
  Future<List<Map<String, Object?>>> readAll() async {
    final db = await _open();
    return db.query(tableHs);
  }
}
