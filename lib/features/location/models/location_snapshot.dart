/// 一次定位的领域模型。
///
/// 页面不依赖鸿蒙平台字段，后续更换定位供应商（例如百度定位）时只替换数据层。
class LocationSnapshot {
  final double latitude;
  final double longitude;
  final double? altitude;
  final String address;

  const LocationSnapshot({
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.address,
  });

  bool get hasAltitude => altitude != null && altitude!.isFinite;
}
