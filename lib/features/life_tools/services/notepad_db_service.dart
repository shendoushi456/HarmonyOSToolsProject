// NotepadDbService - SQLite 数据库封装(单例)
// 对齐 Android third-module/tallynotes/src/main/java/com/example/tallynotes/Database/NotepadDB.java + NoteTB.java + TallyTB.java
// 共享 Notepad.db,包含 note 表(记事本) + tally 表(记账,阶段6用)
// 建表 SQL 对齐 NotepadDB.java:21-32
import 'dart:async';
import 'package:sqflite/sqflite.dart';

class NotepadDbService {
  NotepadDbService._();
  static final NotepadDbService instance = NotepadDbService._();

  Database? _db;

  static const String _dbName = 'Notepad.db';
  static const int _dbVersion = 1;

  // note 表(对齐 NotepadDB.java:21-24)
  static const String tableNote = 'note';
  static const String colNoteId = '_id';
  static const String colNoteContent = 'content';
  static const String colNoteTime = 'notetime';

  // tally 表(对齐 NotepadDB.java:27-32, 阶段6记账用)
  static const String tableTally = 'tally';
  static const String colTallyId = 'id';
  static const String colTallyDate = 'date';
  static const String colTallyType = 'type';
  static const String colTallyMoney = 'money';
  static const String colTallyState = 'state';

  static const String _createTableNote = '''
    create table if not exists $tableNote(
      $colNoteId integer primary key autoincrement,
      $colNoteContent text,
      $colNoteTime text)
  ''';

  static const String _createTableTally = '''
    create table if not exists $tableTally(
      $colTallyId integer primary key autoincrement,
      $colTallyDate text,
      $colTallyType text,
      $colTallyMoney float,
      $colTallyState text)
  ''';

  /// 懒加载打开数据库
  Future<Database> _open() async {
    if (_db != null && _db!.isOpen) return _db!;
    // sqflite 默认数据库目录(getDatabasesPath 由平台实现提供)
    final dir = await getDatabasesPath();
    final path = '$dir/$_dbName';
    _db = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, v) async {
        await db.execute(_createTableNote);
        await db.execute(_createTableTally);
      },
    );
    return _db!;
  }

  // ====== note 表 CRUD(对齐 NoteTB.java) ======

  /// 插入记事 - 对齐 NoteTB.java:44-52 insertData
  Future<int> insertNote(String content, String time) async {
    final db = await _open();
    return db.insert(tableNote, {
      colNoteContent: content,
      colNoteTime: time,
    });
  }

  /// 更新记事 - 对齐 NoteTB.java:54-62 updateData
  Future<int> updateNote(int id, String content, String time) async {
    final db = await _open();
    return db.update(
      tableNote,
      {colNoteContent: content, colNoteTime: time},
      where: '$colNoteId = ?',
      whereArgs: [id],
    );
  }

  /// 删除记事 - 对齐 NoteTB.java:54-62 deleteData
  Future<int> deleteNote(int id) async {
    final db = await _open();
    return db.delete(
      tableNote,
      where: '$colNoteId = ?',
      whereArgs: [id],
    );
  }

  /// 查询全部记事 - 对齐 NoteTB.java:68-89 query(ORDER BY _id DESC)
  Future<List<Map<String, dynamic>>> queryNotes() async {
    final db = await _open();
    return db.query(
      tableNote,
      orderBy: '$colNoteId DESC',
    );
  }

  // ====== tally 表 CRUD(对齐 TallyTB.java, 阶段6记账用) ======

  /// 插入记账 - 对齐 TallyTB.java:48-64 insert
  Future<int> insertTally(String date, String type, double money, String state) async {
    final db = await _open();
    return db.insert(tableTally, {
      colTallyDate: date,
      colTallyType: type,
      colTallyMoney: money,
      colTallyState: state,
    });
  }

  /// 更新记账 - 对齐 TallyTB.java:164-173 update
  Future<int> updateTally(int id, String date, String type, double money, String state) async {
    final db = await _open();
    return db.update(
      tableTally,
      {
        colTallyDate: date,
        colTallyType: type,
        colTallyMoney: money,
        colTallyState: state,
      },
      where: '$colTallyId = ?',
      whereArgs: [id],
    );
  }

  /// 删除记账 - 对齐 TallyTB.java:67-76 delete
  Future<int> deleteTally(int id) async {
    final db = await _open();
    return db.delete(
      tableTally,
      where: '$colTallyId = ?',
      whereArgs: [id],
    );
  }

  /// 查询全部记账 - 对齐 TallyTB.java:131-161 query(ORDER BY date DESC)
  Future<List<Map<String, dynamic>>> queryTally() async {
    final db = await _open();
    return db.query(
      tableTally,
      orderBy: '$colTallyDate DESC',
    );
  }

  /// 关闭数据库(可选,通常不调用,随 App 生命周期)
  Future<void> close() async {
    if (_db != null && _db!.isOpen) {
      await _db!.close();
      _db = null;
    }
  }
}
