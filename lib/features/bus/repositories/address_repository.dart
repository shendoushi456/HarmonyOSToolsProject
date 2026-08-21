// 地址 Repository - 对齐 Android bus/repository/AddressRepository.kt
// 管理地址信息和通勤方式的持久化存储
// 鸿蒙端差异：Android 用 NewSharePreferenceUtils + Gson，Flutter 用 SharedPreferences + jsonEncode/jsonDecode
import 'package:shared_preferences/shared_preferences.dart';
import '../models/address_info.dart';

/// 地址 Repository - 对齐 Android AddressRepository（单例）
/// 管理地址信息和通勤方式的持久化存储
class AddressRepository {
  AddressRepository._internal();

  static final AddressRepository _instance = AddressRepository._internal();
  static AddressRepository get instance => _instance;

  /// SharedPreferences 实例（鸿蒙端用 shared_preferences_ohos 适配）
  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  // 持久化 key（对齐 Android companion 常量）
  static const String _keyTransportMode = 'TRANSPORT_MODE';
  static const String _keyCompanyAddress = 'COMPANY_ADDRESS';
  static const String _keyHomeAddress = 'HOME_ADDRESS';
  static const String _keySchoolAddress = 'SCHOOL_ADDRESS';

  /// 获取默认交通方式 - 对齐 Android getDefaultTransportMode
  /// 注意：Android 端同步返回，Flutter 端 SharedPreferences 异步，提供同步缓存版本
  TransportMode? _cachedTransportMode;

  Future<TransportMode> getDefaultTransportMode() async {
    if (_cachedTransportMode != null) return _cachedTransportMode!;
    final prefs = await _prefs;
    final modeStr =
        prefs.getString(_keyTransportMode) ?? TransportMode.publicTransport.name;
    _cachedTransportMode = TransportMode.fromPersistentName(modeStr);
    return _cachedTransportMode!;
  }

  /// 保存默认交通方式 - 对齐 Android saveDefaultTransportMode
  Future<void> saveDefaultTransportMode(TransportMode mode) async {
    _cachedTransportMode = mode;
    final prefs = await _prefs;
    await prefs.setString(_keyTransportMode, mode.persistentName);
  }

  /// 获取地址信息 - 对齐 Android getAddress
  Future<AddressInfo?> getAddress(AddressType type) async {
    final String key = _keyForType(type);
    final prefs = await _prefs;
    final String addressJson = prefs.getString(key) ?? '';
    if (addressJson.isEmpty) return null;
    try {
      return AddressInfo.fromJsonString(addressJson);
    } catch (e) {
      return null;
    }
  }

  /// 保存地址信息 - 对齐 Android saveAddress
  Future<void> saveAddress(AddressType type, AddressInfo address) async {
    final String key = _keyForType(type);
    final prefs = await _prefs;
    await prefs.setString(key, address.toJsonString());
  }

  /// 删除地址信息 - 对齐 Android deleteAddress
  Future<void> deleteAddress(AddressType type) async {
    final String key = _keyForType(type);
    final prefs = await _prefs;
    await prefs.setString(key, '');
  }

  /// 根据 AddressType 获取对应持久化 key
  String _keyForType(AddressType type) {
    switch (type) {
      case AddressType.company:
        return _keyCompanyAddress;
      case AddressType.home:
        return _keyHomeAddress;
      case AddressType.school:
        return _keySchoolAddress;
    }
  }
}
