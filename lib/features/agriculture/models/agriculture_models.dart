// NongyeFragment 的领域模型；数据与展示解耦，替换马甲 UI 时无需迁移业务规则。
import '../../weather/models/weather_warning.dart';

class CropRecord {
  final String id;
  final String categoryId;
  final String title;
  final String content;
  final DateTime createdAt;

  const CropRecord({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'categoryId': categoryId,
        'title': title,
        'content': content,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  factory CropRecord.fromJson(Map<String, dynamic> json) => CropRecord(
        id: json['id']?.toString() ?? '',
        categoryId: json['categoryId']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        content: json['content']?.toString() ?? '',
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          (json['createdAt'] as num?)?.toInt() ?? 0,
        ),
      );
}

class DisasterGuide {
  final String title;
  final String danger;
  final String prevention;

  /// 指南前置标签，默认"预防措施："；对齐 Android oil_field 干旱指南
  /// 误配的 preventionLabel="危害："（保真保留）
  final String preventionLabel;
  final int color;
  final List<String> aliases;
  final Set<String> eventCodes;

  const DisasterGuide({
    required this.title,
    required this.danger,
    required this.prevention,
    required this.color,
    this.preventionLabel = '预防措施：',
    this.aliases = const [],
    this.eventCodes = const {},
  });

  bool matches(WeatherWarning warning) {
    if (warning.eventCode.isNotEmpty &&
        eventCodes.contains(warning.eventCode)) {
      return true;
    }
    // 对齐 Android warningAliases 默认值 listOf(title)
    final effectiveAliases = aliases.isEmpty ? [title] : aliases;
    final text = '${warning.eventName} ${warning.headline}';
    return effectiveAliases.any(text.contains);
  }
}

class CropCategory {
  final String id;
  final String title;
  final String selectionText;
  final String inputHint;
  final String iconAsset;
  final List<DisasterGuide> guides;

  const CropCategory({
    required this.id,
    required this.title,
    required this.selectionText,
    required this.inputHint,
    required this.iconAsset,
    required this.guides,
  });
}
