// 百度地图 SDK 初始化 - 对齐 Android bus/utils/BaiduSdkInitializer.kt
// 鸿蒙端 API 差异：
// - Android: SDKInitializer.setAgreePrivacy + LocationClient.setAgreePrivacy + SDKInitializer.initialize
// - 鸿蒙 Flutter: BMFMapSDK.setAgreePrivacy + LocationFlutterPlugin.setAgreePrivacy + BMFMapSDK.setApiKeyAndCoordType
import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bmflocation/flutter_bmflocation.dart';

/// 统一初始化百度地图与定位 SDK - 对齐 Android BaiduSdkInitializer
/// 首页可直接跳转到路线或附近地图页，不能依赖主页面已提前初始化 SDK；
/// 否则 RoutePlanSearch 或 MapView 在部分启动路径下会因 SDK 尚未就绪而崩溃。
class BaiduSdkInitializer {
  BaiduSdkInitializer._();

  /// 鸿蒙端百度地图 AK（CODEBUDDY.md 指定，用户确认为鸿蒙端 AK）
  static const String _harmonyAk = 'lryPVHPiTucUqNhDFv2n7AfcGPOF4Bm6';

  /// 定位插件单例（对齐 Android LocationClient 单例语义）
  static final LocationFlutterPlugin _locationPlugin = LocationFlutterPlugin();

  /// 是否已完成初始化（对齐 Android SDKInitializer.isInitialized）
  static bool _initialized = false;

  /// 进行中的初始化任务。多个页面同时进入时复用同一个任务，避免定位插件在
  /// 隐私协议和 AK 尚未设置完成时被重复调用。
  static Future<bool>? _initialization;

  /// 获取定位插件实例（供 BaiduLocationManager 使用）
  static LocationFlutterPlugin get locationPlugin => _locationPlugin;

  /// 定位鉴权失败诊断时使用，与 authAK 提交给百度定位 SDK 的值一致。
  static String get harmonyLocationAkForDiagnostics => _harmonyAk;

  /// 确保 SDK 已初始化 - 对齐 Android BaiduSdkInitializer.ensureInitialized
  /// 调用方仍会以可恢复的错误状态展示页面，不让 SDK 初始化异常直接终止应用。
  static Future<bool> ensureInitialized() {
    if (_initialized) return Future.value(true);
    return _initialization ??= _initialize();
  }

  static Future<bool> _initialize() async {
    try {
      // 1. 隐私合规（对齐 Android SDKInitializer.setAgreePrivacy + LocationClient.setAgreePrivacy）
      // 鸿蒙端 SDK 2.0.2 起，调用任何接口前必须先 setAgreePrivacy(true)，否则无法使用
      // BMFMapSDK 当前插件版本将平台调用封装为 void async，无法等待其结果；
      // 先发起调用，再等待定位 SDK 的对应设置完成，保证后续定位不会抢在
      // 隐私协议设置之前执行。
      BMFMapSDK.setAgreePrivacy(true);
      final privacyAccepted = await _locationPlugin.setAgreePrivacy(true);
      if (!privacyAccepted) {
        throw StateError('百度定位 SDK 隐私协议设置失败');
      }

      // 2. 地图 SDK 初始化 + 坐标系设置（对齐 Android SDKInitializer.initialize）
      // 鸿蒙端通过 setApiKeyAndCoordType 完成 AK 授权 + 坐标系设置
      debugPrint('[BaiduLocation] submit map AK: $_harmonyAk');
      BMFMapSDK.setApiKeyAndCoordType(_harmonyAk, BMF_COORD_TYPE.BD09LL);

      // 3. 定位 SDK 授权 AK（鸿蒙端通过代码 authAK，非 manifest meta-data）
      // 原生 FlutterBmflocationPlugin 会通过同名 channel 回传 checkAuthKey 的
      // result；注册回调后可在 Flutter/DevEco 日志中看到百度服务端的真实鉴权结果。
      _locationPlugin.getApiKeyCallback(callback: (result) {
        debugPrint('[BaiduLocation] checkAuthKey result: $result');
      });
      debugPrint('[BaiduLocation] submit location AK: $_harmonyAk');
      final akSubmitted = await _locationPlugin.authAK(_harmonyAk);
      debugPrint('[BaiduLocation] location AK submit accepted: $akSubmitted');
      if (!akSubmitted) {
        throw StateError('百度定位 SDK AK 设置失败');
      }

      _initialized = true;
      return true;
    } catch (e) {
      // 调用方仍会以可恢复的错误状态展示页面，不让 SDK 初始化异常直接终止应用。
      // 对齐 Android BaiduSdkInitializer.ensureInitialized 的 catch 行为
      print('百度地图 SDK 初始化失败: $e');
      _initialization = null;
      return false;
    }
  }

  /// 是否已初始化（对齐 Android SDKInitializer.isInitialized）
  static bool isInitialized() => _initialized;
}
