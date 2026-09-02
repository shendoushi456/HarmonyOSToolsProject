// 和风 Weather Alert 领域模型。农业和长途规划共享，避免 UI 直接依赖接口 JSON。
import 'dart:convert';

class WeatherWarning {
  final String id;
  final String eventName;
  final String eventCode;
  final String severity;
  final String colorCode;
  final int? red;
  final int? green;
  final int? blue;
  final String headline;
  final String description;
  final String criteria;
  final String instruction;
  final String senderName;
  final String expireTime;
  final String messageType;

  const WeatherWarning({
    required this.id,
    required this.eventName,
    required this.eventCode,
    required this.severity,
    required this.colorCode,
    this.red,
    this.green,
    this.blue,
    required this.headline,
    required this.description,
    required this.criteria,
    required this.instruction,
    required this.senderName,
    required this.expireTime,
    required this.messageType,
  });
}

class WeatherWarningResponse {
  final bool zeroResult;
  final List<WeatherWarning> warnings;

  const WeatherWarningResponse(
      {required this.zeroResult, required this.warnings});

  List<WeatherWarning> get activeWarnings => zeroResult
      ? const []
      : warnings
          .where((warning) => warning.messageType.toLowerCase() != 'cancel')
          .toList();

  static WeatherWarningResponse fromJsonString(String source) {
    try {
      final json = jsonDecode(source) as Map<String, dynamic>;
      final metadata = json['metadata'] as Map<String, dynamic>?;
      final alerts = (json['alerts'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(_warningFromJson)
          .toList();
      return WeatherWarningResponse(
        zeroResult: metadata?['zeroResult'] == true,
        warnings: alerts,
      );
    } catch (_) {
      return const WeatherWarningResponse(zeroResult: true, warnings: []);
    }
  }

  static WeatherWarning _warningFromJson(Map<String, dynamic> json) {
    final event = json['eventType'] as Map<String, dynamic>? ?? const {};
    final color = json['color'] as Map<String, dynamic>? ?? const {};
    final messageType =
        json['messageType'] as Map<String, dynamic>? ?? const {};
    int? number(dynamic value) =>
        value is int ? value : int.tryParse(value?.toString() ?? '');
    return WeatherWarning(
      id: json['id']?.toString() ?? '',
      eventName: event['name']?.toString() ?? '',
      eventCode: event['code']?.toString() ?? '',
      severity: json['severity']?.toString() ?? '',
      colorCode: color['code']?.toString() ?? '',
      red: number(color['red']),
      green: number(color['green']),
      blue: number(color['blue']),
      headline: json['headline']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      criteria: json['criteria']?.toString() ?? '',
      instruction: json['instruction']?.toString() ?? '',
      senderName: json['senderName']?.toString() ?? '',
      expireTime: json['expireTime']?.toString() ?? '',
      messageType: messageType['code']?.toString() ?? '',
    );
  }
}
