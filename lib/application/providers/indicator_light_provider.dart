import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/indicator_light_repository.dart';
import '../../domain/models/indicator_light.dart';

/// 指示灯仓库 provider
/// 对应 Android: CarIndicatorLightActivity.getData()
final indicatorLightRepositoryProvider = Provider<IndicatorLightRepository>((ref) {
  return IndicatorLightRepository();
});

/// 全部指示灯列表
final indicatorLightListProvider = Provider<List<IndicatorLight>>((ref) {
  return ref.watch(indicatorLightRepositoryProvider).getAll();
});
