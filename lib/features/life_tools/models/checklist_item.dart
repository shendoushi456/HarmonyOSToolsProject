// ChecklistItem - 旅行清单 Model
// 对齐 Android third-module/toDoListlib/src/main/java/com/base/todolist/viewModel/TravelChecklistViewModel.kt:13-23
import 'package:flutter/foundation.dart';

@immutable
class ChecklistItem {
  const ChecklistItem({
    required this.id,
    required this.text,
    this.isChecked = false,
  });

  final int id;
  final String text;
  final bool isChecked;

  ChecklistItem copyWith({bool? isChecked}) {
    return ChecklistItem(id: id, text: text, isChecked: isChecked ?? this.isChecked);
  }
}

@immutable
class ChecklistSection {
  const ChecklistSection({required this.title, required this.items});

  final String title;
  final List<ChecklistItem> items;

  ChecklistSection copyWith({List<ChecklistItem>? items}) {
    return ChecklistSection(title: title, items: items ?? this.items);
  }
}
