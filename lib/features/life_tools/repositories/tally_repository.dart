// TallyRepository - 记账数据仓库
// 对齐 Android third-module/tallynotes/src/main/java/com/example/tallynotes/Database/TallyTB.java
import '../models/tally_bean.dart';
import '../services/notepad_db_service.dart';

class TallyRepository {
  TallyRepository([NotepadDbService? dbService])
      : _dbService = dbService ?? NotepadDbService.instance;

  final NotepadDbService _dbService;

  /// 查询全部记账 - 对齐 TallyTB.java:131-161 query(ORDER BY date DESC)
  Future<List<Tally>> queryTally() async {
    final maps = await _dbService.queryTally();
    final list = maps.map(Tally.fromMap).toList();
    // sortListByDate desc - 对齐 ManageActivity.java:400-407
    list.sort((a, b) => b.tallyTime.compareTo(a.tallyTime));
    return list;
  }

  /// 新增记账 - 对齐 TallyTB.java:48-64 insert
  Future<int> insertTally(String date, String type, double money, String state) {
    return _dbService.insertTally(date, type, money, state);
  }

  /// 更新记账 - 对齐 TallyTB.java:164-173 update
  Future<int> updateTally(int id, String date, String type, double money, String state) {
    return _dbService.updateTally(id, date, type, money, state);
  }

  /// 删除记账 - 对齐 TallyTB.java:67-76 delete
  Future<int> deleteTally(int id) {
    return _dbService.deleteTally(id);
  }
}
