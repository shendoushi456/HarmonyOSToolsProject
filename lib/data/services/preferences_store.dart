import 'package:shared_preferences/shared_preferences.dart';

/// 仅保存稳定的食谱 id，避免 Android 版按标题、列表位置双写造成的数据错配。
class PreferencesStore {
  PreferencesStore(this._preferences);

  static const _privacyAccepted = 'privacy_accepted_v1';
  static const _onboardingDone = 'recipe_onboarding_done_v1';
  static const _favoriteIds = 'recipe_favorite_ids_v1';
  static const _recentIds = 'recipe_recent_ids_v1';
  static const _maxRecentCount = 30;

  /// 设置页"个性化推荐"开关，key 与 Android 版 myPreferences.isSetting 一致。
  static const _isSetting = 'isSetting';

  final SharedPreferences _preferences;

  bool get isPrivacyAccepted => _preferences.getBool(_privacyAccepted) ?? false;
  bool get isOnboardingDone => _preferences.getBool(_onboardingDone) ?? false;
  bool get isSetting => _preferences.getBool(_isSetting) ?? false;
  Set<int> get favoriteIds => _readIds(_favoriteIds).toSet();
  List<int> get recentIds => _readIds(_recentIds);

  Future<void> acceptPrivacy() => _preferences.setBool(_privacyAccepted, true);
  Future<void> completeOnboarding() =>
      _preferences.setBool(_onboardingDone, true);
  Future<void> saveIsSetting(bool value) => _preferences.setBool(_isSetting, value);

  Future<void> saveFavoriteIds(Set<int> ids) =>
      _preferences.setStringList(_favoriteIds, ids.map((id) => '$id').toList());

  Future<void> recordRecent(int id) {
    final ids = recentIds.where((value) => value != id).toList();
    ids.insert(0, id);
    return _preferences.setStringList(
      _recentIds,
      ids.take(_maxRecentCount).map((value) => '$value').toList(),
    );
  }

  List<int> _readIds(String key) =>
      (_preferences.getStringList(key) ?? const [])
          .map(int.tryParse)
          .whereType<int>()
          .toList(growable: false);
}
