import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/car_maintenance_repository.dart';
import '../../domain/models/car_maintenance_item.dart';

/// 汽车养护仓库 provider
final carMaintenanceRepositoryProvider = Provider<CarMaintenanceRepository>((ref) {
  return CarMaintenanceRepository();
});

/// 全部养护项列表
final carMaintenanceListProvider = Provider<List<CarMaintenanceItem>>((ref) {
  return ref.watch(carMaintenanceRepositoryProvider).getAll();
});
