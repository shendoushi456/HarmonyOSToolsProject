// NotebookBean - 记事本数据 Model
// 对齐 Android third-module/tallynotes/src/main/java/com/example/tallynotes/Bean/NotebookBean.java
// 字段对齐 note 表(_id/content/notetime)
import 'package:flutter/foundation.dart';

@immutable
class NotebookBean {
  const NotebookBean({
    this.id,
    required this.content,
    required this.notebookTime,
  });

  /// 记事本记录 id(对齐 note 表 _id)
  final int? id;

  /// 记事内容(对齐 note 表 content)
  final String content;

  /// 记事时间(对齐 note 表 notetime,格式 "yyyy年MM月dd日 HH:mm:ss")
  final String notebookTime;

  /// 从 sqflite Map 构造
  factory NotebookBean.fromMap(Map<String, dynamic> map) {
    return NotebookBean(
      id: map['_id'] as int?,
      content: map['content'] as String? ?? '',
      notebookTime: map['notetime'] as String? ?? '',
    );
  }

  /// 转为 sqflite Map(用于 insert/update)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) '_id': id,
      'content': content,
      'notetime': notebookTime,
    };
  }

  NotebookBean copyWith({
    int? id,
    String? content,
    String? notebookTime,
  }) {
    return NotebookBean(
      id: id ?? this.id,
      content: content ?? this.content,
      notebookTime: notebookTime ?? this.notebookTime,
    );
  }
}
