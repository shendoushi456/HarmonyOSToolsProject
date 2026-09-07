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

  /// 是否同意隐私协议(对齐 Android SPUtil "isAgressment")
  static const String keyIsAgressment = 'isAgressment';

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

  /// 读取是否同意隐私协议 - 对齐 Android SPUtil "isAgressment"
  static bool loadIsAgressment() => _instance.getBool(keyIsAgressment) ?? false;

  /// 保存是否同意隐私协议
  static Future<void> saveIsAgressment(bool value) async {
    await _instance.setBool(keyIsAgressment, value);
  }

  /// 功能模块私有 JSON 存储；避免将农业/长途规划数据混入城市配置。
  static String? getString(String key) => _instance.getString(key);

  /// 返回底层存储是否实际写入成功，调用方不能把失败误报为“已保存”。
  static Future<bool> setString(String key, String value) =>
      _instance.setString(key, value);

  /// 重新向平台读取最新值，避免只用当前进程内缓存判断保存是否成功。
  static Future<void> reload() => _instance.reload();

  /// 撤销协议同意时清除当前应用通过 SharedPreferences 保存的全部本地信息。
  /// 平台插件会只清除本应用带 flutter. 前缀的数据，不会影响其他应用。
  static Future<bool> clearAll() => _instance.clear();
}
