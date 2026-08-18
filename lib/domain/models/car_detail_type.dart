/// 车辆详情图类型
///
/// 对应 Android: toolCarLib/CarDetailJumpTo.kt:11-73 的 when 分支。
/// 每个类型对应一张详情图，enableZoom 表示是否支持缩放。
enum CarDetailType {
  trafficSign('交通标志', 'assets/images/car/ic_car_detail_1.png', true),
  policeGesture('交警手势', 'assets/images/car/ic_car_detail_2.webp', true),
  roadSignal('道路信号', 'assets/images/car/ic_car_detail_3.webp', true),
  hardwareDiagram('硬件图解', 'assets/images/car/ic_car_detail_4.webp', true),
  subjectTwoTips('科二技巧', 'assets/images/car/ic_car_detail_5.webp', true),
  licensePlateType('车牌类型', 'assets/images/car/ic_car_detail_6.webp', false);

  final String label;
  final String assetPath;
  final bool enableZoom;

  const CarDetailType(this.label, this.assetPath, this.enableZoom);

  /// 按中文标签查找（对应 Android CarDetailJumpTo.start(context, type) 的 type 参数）
  static CarDetailType? fromLabel(String label) {
    for (final type in CarDetailType.values) {
      if (type.label == label) return type;
    }
    return null;
  }
}
