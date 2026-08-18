import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/phone_repository.dart';

/// 电话信息仓库 provider
final phoneRepositoryProvider = Provider<PhoneRepository>((ref) {
  return PhoneRepository();
});

/// 应急电话当前 Tab（0=道路救援, 1=保险公司）
/// 对应 Android: TelephoneCarFragment TelephoneCarContent 的 selectedTab
final telephoneTabProvider = StateProvider<int>((ref) => 0);
