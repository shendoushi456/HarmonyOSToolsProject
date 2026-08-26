import 'package:flutter/services.dart';

/// 外部应用跳转服务
///
/// 对应 Android: SearchCarInfoFragment.kt:539-580 openTrafficManagement12123
/// 通过 MethodChannel 调用鸿蒙侧 startAbility 跳转第三方 APP（交管12123）。
/// 鸿蒙侧实现在 EntryAbility.ets 的 MethodChannel handler 中。
class ExternalAppService {
  /// MethodChannel 名称（鸿蒙侧 EntryAbility.ets 中必须一致）
  static const _channel = MethodChannel('hm.lxhy.youyouxing/external_app');

  /// 交管12123 包名（Android 包名 com.tmri.app.main，鸿蒙版 bundleName 可能不同，
  /// 鸿蒙侧 handler 会先尝试此 bundleName，失败则跳应用市场）。
  static const trafficManagement12123Bundle = 'com.tmri.app.main';

  /// 打开指定 bundleName 的应用，未安装则跳应用市场。
  /// 返回 true 表示成功启动，false 表示失败/未安装。
  Future<bool> openApp(String bundleName) async {
    try {
      final result = await _channel.invokeMethod<bool>('openApp', {
        'bundleName': bundleName,
      });
      return result ?? false;
    } on PlatformException catch (_) {
      return false;
    } on MissingPluginException catch (_) {
      // 鸿蒙侧未注册 MethodChannel（开发期占位）
      return false;
    }
  }

  /// 打开交管12123
  Future<bool> openTrafficManagement12123() async {
    return openApp(trafficManagement12123Bundle);
  }

  /// 拨打电话
  ///
  /// 对应 Android: TelephoneCarFragment.kt:69-76 dialPhoneNumber
  /// 将"转"替换为","（拨号暂停），去除空格，通过 MethodChannel 调鸿蒙侧 startAbility({uri: 'tel:xxx'})。
  Future<bool> dialPhone(String phoneNumber) async {
    // 预处理：将"转"替换为","，去除空格（与 Android dialPhoneNumber 一致）
    final dialNumber = phoneNumber.replaceAll('转', ',').replaceAll(' ', '');
    try {
      final result = await _channel.invokeMethod<bool>('dialPhone', {
        'phone': dialNumber,
      });
      return result ?? false;
    } on PlatformException catch (_) {
      return false;
    } on MissingPluginException catch (_) {
      return false;
    }
  }

  /// 在系统浏览器中打开外部 URL。
  ///
  /// 设置页的协议链接由 PolicyPage 中的项目内 ArkWeb 视图加载，
  /// 不走此方法。
  Future<bool> openUrl(String url) async {
    try {
      final result = await _channel.invokeMethod<bool>('openUrl', {
        'url': url,
      });
      return result ?? false;
    } on PlatformException catch (_) {
      return false;
    } on MissingPluginException catch (_) {
      return false;
    }
  }

  /// 获取应用版本号
  ///
  /// 对应 Android: SystemUtilTool.getVersionName
  /// 通过 MethodChannel 调鸿蒙侧 bundleManager.getBundleInfoForSelf。
  Future<String> getAppVersion() async {
    try {
      final result = await _channel.invokeMethod<String>('getAppVersion');
      return result ?? '1.0.1';
    } on PlatformException catch (_) {
      return '1.0.1';
    } on MissingPluginException catch (_) {
      return '1.0.1';
    }
  }

  /// 读取布尔偏好值
  ///
  /// 对应 Android: SPUtil.with(ctx).load().read(key, default)
  /// 通过 MethodChannel 调鸿蒙侧 @ohos.data.preferences。
  Future<bool> getBool(String key, bool defaultValue) async {
    try {
      final result = await _channel.invokeMethod<bool>('getBool', {
        'key': key,
        'defaultValue': defaultValue,
      });
      return result ?? defaultValue;
    } on PlatformException catch (_) {
      return defaultValue;
    } on MissingPluginException catch (_) {
      return defaultValue;
    }
  }

  /// 保存布尔偏好值
  ///
  /// 对应 Android: SPUtil.with(ctx).load().save(key, value)
  Future<void> setBool(String key, bool value) async {
    try {
      await _channel.invokeMethod<bool>('setBool', {
        'key': key,
        'value': value,
      });
    } on PlatformException catch (_) {
      // 忽略
    } on MissingPluginException catch (_) {
      // 忽略
    }
  }

  /// 终止当前鸿蒙 Ability，用于用户拒绝首次隐私协议等不可继续使用 App 的场景。
  Future<void> exitApp() async {
    try {
      await _channel.invokeMethod<void>('exitApp');
    } on PlatformException catch (_) {
      await SystemNavigator.pop();
    } on MissingPluginException catch (_) {
      await SystemNavigator.pop();
    }
  }
}
