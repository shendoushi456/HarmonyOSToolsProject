import { FlutterAbility, FlutterEngine, MethodChannel, MethodCall, MethodResult } from '@ohos/flutter_ohos';
import { GeneratedPluginRegistrant } from '../plugins/GeneratedPluginRegistrant';
import { PolicyWebViewPlugin } from '../webview/PolicyWebViewPlugin';
import { BusinessError } from '@kit.BasicServicesKit';
import { bundleManager } from '@kit.AbilityKit';
import { preferences } from '@kit.ArkData';
import Want from '@ohos.app.ability.Want';

// MethodChannel 名称（Flutter 侧 external_app_service.dart 必须一致）
const CHANNEL_NAME = 'hm.lxhy.youyouxing/external_app';

// 交管12123 鸿蒙版 bundleName：需在真机用 hdc shell bm dump -a 确认后更新
// Android 版包名为 com.tmri.app.main，鸿蒙版 bundleName 不一定相同
const DEFAULT_ABILITY_NAME = 'EntryAbility';

// Flutter 宿主 Ability：接管 UI 渲染 + MethodChannel 跳转第三方 APP
export default class EntryAbility extends FlutterAbility {
  configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    GeneratedPluginRegistrant.registerWith(flutterEngine)
    // 项目内 PlatformView 不属于 pub 插件，必须在此手动注册；
    // 不放在 GeneratedPluginRegistrant，避免 flutter pub get 后被覆盖。
    flutterEngine.getPlugins()?.add(new PolicyWebViewPlugin())

    // 注册 MethodChannel：接收 Flutter 侧 openApp 调用
    const messenger = flutterEngine.getDartExecutor().getBinaryMessenger()
    new MethodChannel(messenger, CHANNEL_NAME).setMethodCallHandler({
      onMethodCall: (call: MethodCall, result: MethodResult) => {
        if (call.method === 'openApp') {
          this.openApp(call, result)
        } else if (call.method === 'dialPhone') {
          this.dialPhone(call, result)
        } else if (call.method === 'openUrl') {
          this.openUrl(call, result)
        } else if (call.method === 'getAppVersion') {
          this.getAppVersion(result)
        } else if (call.method === 'getBool') {
          this.getBool(call, result)
        } else if (call.method === 'setBool') {
          this.setBool(call, result)
        } else if (call.method === 'exitApp') {
          this.exitApp(result)
        } else {
          result.notImplemented()
        }
      }
    })
  }

  /**
   * 启动第三方 App：
   * - 已安装：用 startAbility 拉起
   * - 未安装/失败：跳转到华为应用市场详情页
   * 对应 Android: SearchCarInfoFragment.openTrafficManagement12123
   * （startActivity → 失败回退 market://details?id=）
   */
  private async openApp(call: MethodCall, result: MethodResult) {
    let bundleName: string = ''
    if (call.hasArgument('bundleName')) {
      bundleName = String(call.argument('bundleName'))
    }
    if (!bundleName) {
      result.error('INVALID_ARGS', 'bundleName 不能为空', null)
      return
    }
    const abilityName: string = call.hasArgument('abilityName')
      ? String(call.argument('abilityName'))
      : DEFAULT_ABILITY_NAME

    try {
      // 1) 直接尝试启动目标 App（目标 ability 需 exported: true）
      await this.context.startAbility({
        bundleName: bundleName,
        abilityName: abilityName,
      } as Want)
      result.success(true)
    } catch (e) {
      // 2) 失败回退：跳转华为应用市场详情页
      try {
        const want: Want = {
          uri: `store://appgallery.huawei.com/app/detail?id=${bundleName}`
        }
        await this.context.startAbility(want)
        result.success(true)
      } catch (e2) {
        const err2 = e2 as BusinessError
        result.error(`${err2.code}`, err2.message, null)
      }
    }
  }

  /**
   * 拨打电话
   * 对应 Android: TelephoneCarFragment.dialPhoneNumber
   * 通过 startAbility({uri: 'tel:xxx'}) 拉起系统拨号界面
   */
  private async dialPhone(call: MethodCall, result: MethodResult) {
    let phone: string = ''
    if (call.hasArgument('phone')) {
      phone = String(call.argument('phone'))
    }
    if (!phone) {
      result.error('INVALID_ARGS', 'phone 不能为空', null)
      return
    }
    try {
      const want: Want = {
        uri: `tel:${phone}`
      }
      await this.context.startAbility(want)
      result.success(true)
    } catch (e) {
      const err = e as BusinessError
      result.error(`${err.code}`, err.message, null)
    }
  }

  /**
   * 在系统浏览器中打开外部 URL。
   * 设置页协议由项目内 ArkWeb PlatformView 加载，不经过此方法。
   */
  private async openUrl(call: MethodCall, result: MethodResult) {
    let url: string = ''
    if (call.hasArgument('url')) {
      url = String(call.argument('url'))
    }
    if (!url) {
      result.error('INVALID_ARGS', 'url 不能为空', null)
      return
    }
    try {
      const want: Want = { uri: url }
      await this.context.startAbility(want)
      result.success(true)
    } catch (e) {
      const err = e as BusinessError
      result.error(`${err.code}`, err.message, null)
    }
  }

  /**
   * 获取应用版本号
   * 对应 Android: SystemUtilTool.getVersionName
   * 通过 bundleManager.getBundleInfoForSelf 获取 versionName。
   */
  private async getAppVersion(result: MethodResult) {
    try {
      const bundleInfo = await bundleManager.getBundleInfoForSelf(
        bundleManager.BundleFlag.GET_BUNDLE_INFO_DEFAULT
      )
      result.success(bundleInfo.versionName)
    } catch (e) {
      const err = e as BusinessError
      result.error(`${err.code}`, err.message, null)
    }
  }

  /**
   * 读取布尔偏好值
   * 对应 Android: SPUtil SharedPreferences "myPreferences"
   */
  private async getBool(call: MethodCall, result: MethodResult) {
    const key = String(call.argument('key'))
    const defaultValue = call.hasArgument('defaultValue')
      ? Boolean(call.argument('defaultValue'))
      : false
    try {
      const pref = await preferences.getPreferences(this.context, 'myPreferences')
      const value = await pref.get(key, defaultValue)
      result.success(Boolean(value))
    } catch (e) {
      result.success(defaultValue)
    }
  }

  /**
   * 保存布尔偏好值
   */
  private async setBool(call: MethodCall, result: MethodResult) {
    const key = String(call.argument('key'))
    const value = Boolean(call.argument('value'))
    try {
      const pref = await preferences.getPreferences(this.context, 'myPreferences')
      await pref.put(key, value)
      await pref.flush()
      result.success(true)
    } catch (e) {
      result.success(false)
    }
  }

  /**
   * 终止当前 Ability。用于用户拒绝首次隐私协议时退出 App。
   */
  private async exitApp(result: MethodResult) {
    try {
      await this.context.terminateSelf()
      result.success(true)
    } catch (e) {
      const err = e as BusinessError
      result.error(`${err.code}`, err.message, null)
    }
  }
}
