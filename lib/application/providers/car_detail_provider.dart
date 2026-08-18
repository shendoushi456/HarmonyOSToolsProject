import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/car_detail_repository.dart';
import '../../domain/models/car_detail_type.dart';

/// 车辆详情图仓库 provider
final carDetailRepositoryProvider = Provider<CarDetailRepository>((ref) {
  return CarDetailRepository();
});

/// 按中文标签查找详情类型
/// 对应 Android: CarDetailJumpTo.start(context, type) 的 type 参数
final carDetailByLabelProvider =
    Provider.family<CarDetailType?, String>((ref, label) {
  return ref.watch(carDetailRepositoryProvider).findByLabel(label);
});
