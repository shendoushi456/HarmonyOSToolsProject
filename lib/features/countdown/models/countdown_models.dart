import 'package:flutter/foundation.dart';

/// 倒数日数据模型 - 对齐 Android CountdownEntity。
@immutable
class CountdownItem {
  final int id;
  final String title;
  final DateTime targetDate;
  final bool isPinned;
  final bool isRepeatYearly;
  final int colorIndex;
  final int createdAt;
  final int updatedAt;
  final bool isActive;

  const CountdownItem({
    required this.id,
    required this.title,
    required this.targetDate,
    required this.isPinned,
    required this.isRepeatYearly,
    required this.colorIndex,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  CountdownItem copyWith({
    String? title,
    DateTime? targetDate,
    bool? isPinned,
    bool? isRepeatYearly,
    int? colorIndex,
    int? updatedAt,
    bool? isActive,
  }) =>
      CountdownItem(
        id: id,
        title: title ?? this.title,
        targetDate: targetDate ?? this.targetDate,
        isPinned: isPinned ?? this.isPinned,
        isRepeatYearly: isRepeatYearly ?? this.isRepeatYearly,
        colorIndex: colorIndex ?? this.colorIndex,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isActive: isActive ?? this.isActive,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'targetDate': _dateOnly(targetDate),
        'isPinned': isPinned,
        'isRepeatYearly': isRepeatYearly,
        'colorIndex': colorIndex,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'isActive': isActive,
      };

  factory CountdownItem.fromJson(Map<String, dynamic> json) =>
      CountdownItem(
        id: (json['id'] as num?)?.toInt() ?? 0,
        title: json['title']?.toString() ?? '',
        targetDate:
            DateTime.tryParse(json['targetDate']?.toString() ?? '') ??
                DateTime.now(),
        isPinned: json['isPinned'] as bool? ?? false,
        isRepeatYearly: json['isRepeatYearly'] as bool? ?? false,
        colorIndex: (json['colorIndex'] as num?)?.toInt() ?? 0,
        createdAt: (json['createdAt'] as num?)?.toInt() ?? 0,
        updatedAt: (json['updatedAt'] as num?)?.toInt() ?? 0,
        isActive: json['isActive'] as bool? ?? true,
      );
}

String _dateOnly(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
