import '../../domain/models/car_detail_type.dart';

/// 车辆详情图仓库
///
/// 对应 Android: toolCarLib/CarDetailJumpTo.kt
/// 按 type 标签查找对应的详情图。
class CarDetailRepository {
  /// 按中文标签查找详情类型
  CarDetailType? findByLabel(String label) => CarDetailType.fromLabel(label);

  /// 所有详情类型
  List<CarDetailType> getAll() => CarDetailType.values;
}
