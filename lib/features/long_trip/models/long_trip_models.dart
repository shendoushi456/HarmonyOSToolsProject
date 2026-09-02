import '../../weather/models/weather_model.dart';
import '../../weather/models/weather_warning.dart';

enum LongTripPointRole { start, waypoint, end }

extension LongTripPointRoleText on LongTripPointRole {
  String get label {
    switch (this) {
      case LongTripPointRole.start:
        return '起点';
      case LongTripPointRole.waypoint:
        return '途径点';
      case LongTripPointRole.end:
        return '终点';
    }
  }
}

class LongTripPoint {
  final String cityName;
  final DateTime date;
  const LongTripPoint({required this.cityName, required this.date});
  Map<String, dynamic> toJson() =>
      {'cityName': cityName, 'date': date.toIso8601String()};
  factory LongTripPoint.fromJson(Map<String, dynamic> json) => LongTripPoint(
        cityName: json['cityName']?.toString() ?? '',
        date:
            DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      );
}

class LongTripPlan {
  final String id;
  final LongTripPoint start;
  final List<LongTripPoint> waypoints;
  final LongTripPoint end;
  final DateTime createdAt;
  const LongTripPlan(
      {required this.id,
      required this.start,
      required this.waypoints,
      required this.end,
      required this.createdAt});
  List<LongTripPoint> get points => [start, ...waypoints, end];
  Map<String, dynamic> toJson() => {
        'id': id,
        'start': start.toJson(),
        'waypoints': waypoints.map((item) => item.toJson()).toList(),
        'end': end.toJson(),
        'createdAt': createdAt.toIso8601String()
      };
  factory LongTripPlan.fromJson(Map<String, dynamic> json) => LongTripPlan(
        id: json['id']?.toString() ?? '',
        start: LongTripPoint.fromJson(
            json['start'] as Map<String, dynamic>? ?? const {}),
        waypoints: (json['waypoints'] as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(LongTripPoint.fromJson)
            .toList(),
        end: LongTripPoint.fromJson(
            json['end'] as Map<String, dynamic>? ?? const {}),
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
            DateTime.now(),
      );
}

class LongTripDraft {
  final LongTripPoint? start;
  final List<LongTripPoint> waypoints;
  final LongTripPoint? end;
  const LongTripDraft({this.start, this.waypoints = const [], this.end});
  bool get hasContent => start != null || waypoints.isNotEmpty || end != null;
  LongTripDraft copyWith(
          {LongTripPoint? start,
          bool clearStart = false,
          List<LongTripPoint>? waypoints,
          LongTripPoint? end,
          bool clearEnd = false}) =>
      LongTripDraft(
        start: clearStart ? null : start ?? this.start,
        waypoints: waypoints ?? this.waypoints,
        end: clearEnd ? null : end ?? this.end,
      );
}

class LongTripCityWeather {
  final bool loading;
  final List<DailyWeather> forecasts;
  final List<WeatherWarning> warnings;
  const LongTripCityWeather(
      {this.loading = true,
      this.forecasts = const [],
      this.warnings = const []});
}
