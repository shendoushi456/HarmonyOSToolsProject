// SharedPreferences 存储封装 - 对齐 Android SharedPrefUtil
// 存储城市列表、当前位置等
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PrefsStorage {
  PrefsStorage._();

  static SharedPreferences? _prefs;

  /// 初始化(在 app 启动时调用)
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get _instance {
    if (_prefs == null) {
      throw StateError('PrefsStorage 未初始化,请先调用 PrefsStorage.init()');
    }
    return _prefs!;
  }

  /// 城市列表 key(对齐 Android key="city")
  static const String keyCity = 'city';

  /// 当前 ViewPager 位置
  static const String keyFragmentPosition = 'fragment_position';

  /// 是否刚添加城市(用于跳转到新城市)
  static const String keySaveCurrentItem = 'saveCurrentItem';

  /// 保存城市列表 JSON
  static Future<void> saveCityList(List<Map<String, dynamic>> cities) async {
    final json = jsonEncode(cities);
    await _instance.setString(keyCity, json);
  }

  /// 读取城市列表 JSON
  static List<Map<String, dynamic>>? loadCityList() {
    final json = _instance.getString(keyCity);
    if (json == null) return null;
    final list = jsonDecode(json) as List;
    return list.cast<Map<String, dynamic>>();
  }

  /// 保存当前位置
  static Future<void> savePosition(int position) async {
    await _instance.setInt(keyFragmentPosition, position);
  }

  /// 读取当前位置
  static int loadPosition() => _instance.getInt(keyFragmentPosition) ?? 0;

  /// 保存是否刚添加城市
  static Future<void> saveSaveCurrentItem(bool value) async {
    await _instance.setBool(keySaveCurrentItem, value);
  }

  /// 读取是否刚添加城市
  static bool loadSaveCurrentItem() =>
      _instance.getBool(keySaveCurrentItem) ?? false;
}
