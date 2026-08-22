// NotebookRepository - 记事本数据仓库
// 对齐 Android third-module/tallynotes/src/main/java/com/example/tallynotes/Database/NoteTB.java
// 持有 NotepadDbService,做 note 表 CRUD + Map→NotebookBean 转换
import '../models/notebook_bean.dart';
import '../services/notepad_db_service.dart';

class NotebookRepository {
  NotebookRepository([NotepadDbService? dbService])
      : _dbService = dbService ?? NotepadDbService.instance;

  final NotepadDbService _dbService;

  /// 查询全部记事 - 对齐 NoteTB.java:68-89 query
  Future<List<NotebookBean>> queryNotes() async {
    final maps = await _dbService.queryNotes();
    return maps.map(NotebookBean.fromMap).toList();
  }

  /// 新增记事 - 对齐 NoteTB.java:44-52 insertData
  Future<int> insertNote(String content, String time) {
    return _dbService.insertNote(content, time);
  }

  /// 更新记事 - 对齐 NoteTB.java:54-62 updateData
  Future<int> updateNote(int id, String content, String time) {
    return _dbService.updateNote(id, content, time);
  }

  /// 删除记事 - 对齐 NoteTB.java:54-62 deleteData
  Future<int> deleteNote(int id) {
    return _dbService.deleteNote(id);
  }
}
