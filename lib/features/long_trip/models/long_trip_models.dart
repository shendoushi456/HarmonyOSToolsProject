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

  /// 内置城市目录 ID；与和风天气 locationId 区分。
  final String sourceId;

  /// 和风天气 location ID。旧数据没有该字段时为空，读取后可重新定位。
  final String locationId;
  final String provinceName;
  final String adminCityName;
  final String latitude;
  final String longitude;
  final DateTime date;

  /// 在整条路线中的稳定顺序：起点为 0，途径点依次递增，终点为最后一项。
  final int sequence;

  const LongTripPoint({
    required this.cityName,
    required this.date,
    this.locationId = '',
    this.sourceId = '',
    this.provinceName = '',
    this.adminCityName = '',
    this.latitude = '',
    this.longitude = '',
    this.sequence = 0,
  });

  factory LongTripPoint.fromCity({
    required String cityName,
    required DateTime date,
    String locationId = '',
    String sourceId = '',
    String provinceName = '',
    String adminCityName = '',
    String latitude = '',
    String longitude = '',
  }) =>
      LongTripPoint(
        cityName: cityName,
        date: date,
        locationId: locationId,
        sourceId: sourceId,
        provinceName: provinceName,
        adminCityName: adminCityName,
        latitude: latitude,
        longitude: longitude,
      );

  LongTripPoint copyWith({
    String? cityName,
    DateTime? date,
    String? locationId,
    String? sourceId,
    String? provinceName,
    String? adminCityName,
    String? latitude,
    String? longitude,
    int? sequence,
  }) =>
      LongTripPoint(
        cityName: cityName ?? this.cityName,
        date: date ?? this.date,
        locationId: locationId ?? this.locationId,
        sourceId: sourceId ?? this.sourceId,
        provinceName: provinceName ?? this.provinceName,
        adminCityName: adminCityName ?? this.adminCityName,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        sequence: sequence ?? this.sequence,
      );

  /// 天气缓存和去重使用和风 locationId，离线记录退回目录 ID 或城市名。
  String get weatherKey {
    if (locationId.trim().isNotEmpty) return 'id:$locationId';
    if (sourceId.trim().isNotEmpty) return 'source:$sourceId';
    return 'name:${cityName.trim()}';
  }

  /// 路线去重优先使用离线可获得且稳定的目录 ID；没有时再用天气 locationId。
  String get routeIdentity {
    if (sourceId.trim().isNotEmpty) return 'source:$sourceId';
    if (locationId.trim().isNotEmpty) return 'location:$locationId';
    return 'name:${cityName.trim()}';
  }

  String get routeDate =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> toJson() => {
        'cityName': cityName,
        'locationId': locationId,
        'sourceId': sourceId,
        'provinceName': provinceName,
        'adminCityName': adminCityName,
        'latitude': latitude,
        'longitude': longitude,
        'date': date.toIso8601String(),
        'sequence': sequence,
      };
  factory LongTripPoint.fromJson(Map<String, dynamic> json) => LongTripPoint(
        cityName: json['cityName']?.toString() ?? '',
        locationId: json['locationId']?.toString() ?? '',
        sourceId: json['sourceId']?.toString() ?? '',
        provinceName: json['provinceName']?.toString() ?? '',
        adminCityName: json['adminCityName']?.toString() ?? '',
        latitude: json['latitude']?.toString() ?? '',
        longitude: json['longitude']?.toString() ?? '',
        date:
            DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
        sequence: json['sequence'] is int
            ? json['sequence'] as int
            : int.tryParse(json['sequence']?.toString() ?? '') ?? 0,
      );
}

/// 城市选择页返回的完整城市信息。与天气首页城市配置分离。
class LongTripCitySelection {
  final String sourceId;
  final String locationId;
  final String provinceName;
  final String adminCityName;
  final String cityName;
  final String latitude;
  final String longitude;

  const LongTripCitySelection({
    required this.locationId,
    this.sourceId = '',
    required this.provinceName,
    required this.adminCityName,
    required this.cityName,
    this.latitude = '',
    this.longitude = '',
  });

  Map<String, dynamic> toJson() => {
        'locationId': locationId,
        'sourceId': sourceId,
        'provinceName': provinceName,
        'adminCityName': adminCityName,
        'cityName': cityName,
        'latitude': latitude,
        'longitude': longitude,
      };

  factory LongTripCitySelection.fromJson(Map<String, dynamic> json) =>
      LongTripCitySelection(
        locationId: json['locationId']?.toString() ?? '',
        sourceId: json['sourceId']?.toString() ?? '',
        provinceName: json['provinceName']?.toString() ?? '',
        adminCityName: json['adminCityName']?.toString() ?? '',
        cityName: json['cityName']?.toString() ?? '',
        latitude: json['latitude']?.toString() ?? '',
        longitude: json['longitude']?.toString() ?? '',
      );

  LongTripPoint toPoint(DateTime date) => LongTripPoint.fromCity(
        cityName: cityName,
        date: date,
        locationId: locationId,
        sourceId: sourceId,
        provinceName: provinceName,
        adminCityName: adminCityName,
        latitude: latitude,
        longitude: longitude,
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

  /// 相同的城市顺序和出行日期生成相同指纹，供保存前去重使用。
  String get routeFingerprint => points
      .map((point) => '${point.routeIdentity}@${point.routeDate}')
      .join('>');
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
