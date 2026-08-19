import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 隐私协议同意状态 Provider
///
/// 对应原 Android `SPUtil` 存储的 `"isAgressment"` 标志。
final NotifierProvider<PrivacyAgreementNotifier, AsyncValue<bool>>
    privacyAgreementProvider =
    NotifierProvider<PrivacyAgreementNotifier, AsyncValue<bool>>(
  PrivacyAgreementNotifier.new,
);

class PrivacyAgreementNotifier extends Notifier<AsyncValue<bool>> {
  static const String _key = 'isAgressment';

  @override
  AsyncValue<bool> build() {
    _load();
    return const AsyncValue.loading();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final agreed = prefs.getBool(_key) ?? false;
    state = AsyncValue.data(agreed);
  }

  /// 标记已同意
  Future<void> agree() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
    state = const AsyncValue.data(true);
  }
}
