import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/driving_license_repository.dart';

/// 驾照扣分仓库 provider
final drivingLicenseRepositoryProvider = Provider<DrivingLicenseRepository>((ref) {
  return DrivingLicenseRepository();
});

/// 驾照扣分当前 Tab 索引（0-4，对应记12/9/6/3/1分）
/// 对应 Android: DrivingLicenseDeductionRulesActivity 的 selectedTabIndex
final drivingLicenseTabProvider = StateProvider<int>((ref) => 0);
