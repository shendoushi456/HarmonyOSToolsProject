import abilityAccessCtrl, { PermissionRequestResult, Permissions } from '@ohos.abilityAccessCtrl';
import bundleManager from '@ohos.bundle.bundleManager';
import { BusinessError } from '@ohos.base';
import common from '@ohos.app.ability.common';
import window from '@ohos.window';
import MethodChannel, { MethodResult } from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodChannel';
import { FlutterEngine, MethodCall } from '@ohos/flutter_ohos';
import Log from '@ohos/flutter_ohos/src/main/ets/util/Log';

const TAG = 'CameraPermissionPlugin';
const CHANNEL_NAME = 'toolbox.camera/permission';
const CAMERA_PERMISSION: Permissions = 'ohos.permission.CAMERA';

// 仅管理权限；实际预览和拍照由 camera_ohos 在当前应用内完成。
export default class CameraPermissionPlugin {
  private channel?: MethodChannel;
  private context?: common.UIAbilityContext;

  static register(flutterEngine: FlutterEngine, context: common.UIAbilityContext): CameraPermissionPlugin {
    const plugin = new CameraPermissionPlugin();
    plugin.attach(flutterEngine, context);
    return plugin;
  }

  private attach(flutterEngine: FlutterEngine, context: common.UIAbilityContext): void {
    this.context = context;
    this.channel = new MethodChannel(flutterEngine.dartExecutor.getBinaryMessenger(), CHANNEL_NAME);
    this.channel.setMethodCallHandler({
      onMethodCall: (call: MethodCall, result: MethodResult): void => {
        if (call.method === 'requestCameraPermission') {
          this.requestCameraPermission(result);
          return;
        }
        // 放大镜页调节屏幕亮度(对齐安卓 setWindowBrightness，窗口级 0~1)
        if (call.method === 'setScreenBrightness') {
          this.setScreenBrightness(call, result);
          return;
        }
        if (call.method === 'getScreenBrightness') {
          this.getScreenBrightness(result);
          return;
        }
        result.notImplemented();
      }
    });
  }

  detach(): void {
    this.channel?.setMethodCallHandler(null);
    this.channel = undefined;
    this.context = undefined;
  }

  private async requestCameraPermission(result: MethodResult): Promise<void> {    if (!this.context) {
      result.error('no_context', '无法获取应用上下文', null);
      return;
    }
    try {
      const manager = abilityAccessCtrl.createAtManager();
      const bundleInfo = await bundleManager.getBundleInfoForSelf(
        bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION
      );
      const granted = await manager.checkAccessToken(bundleInfo.appInfo.accessTokenId, CAMERA_PERMISSION);
      if (granted === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        result.success(true);
        return;
      }
      const response: PermissionRequestResult = await manager.requestPermissionsFromUser(
        this.context,
        [CAMERA_PERMISSION]
      );
      result.success(response.authResults.length > 0 && response.authResults[0] === 0);
    } catch (error) {
      const businessError = error as BusinessError;
      Log.e(TAG, `request camera permission failed: ${businessError.code}, ${businessError.message}`);
      result.error('camera_permission_failed', businessError.message, null);
    }
  }

  // 设置当前窗口亮度，brightness 取值 0~1（-1 恢复跟随系统）
  private async setScreenBrightness(call: MethodCall, result: MethodResult): Promise<void> {
    // 注意：参数必须用 call.argument() 取值，args['key'] 对 Map 实例得 undefined
    const brightness = call.argument('brightness') as number;
    if (!this.context || brightness == null) {
      result.error('bad_args', '上下文或亮度参数缺失', null);
      return;
    }
    try {
      const win = await window.getLastWindow(this.context);
      await win.setWindowBrightness(brightness);
      result.success(true);
    } catch (error) {
      const businessError = error as BusinessError;
      Log.e(TAG, `setScreenBrightness failed: ${businessError.code}, ${businessError.message}`);
      result.error('set_brightness_failed', businessError.message, null);
    }
  }

  // 读取当前窗口亮度，-1 表示跟随系统
  private async getScreenBrightness(result: MethodResult): Promise<void> {
    if (!this.context) {
      result.error('no_context', '无法获取应用上下文', null);
      return;
    }
    try {
      const win = await window.getLastWindow(this.context);
      result.success(win.getWindowProperties().brightness);
    } catch (error) {
      const businessError = error as BusinessError;
      Log.e(TAG, `getScreenBrightness failed: ${businessError.code}, ${businessError.message}`);
      result.error('get_brightness_failed', businessError.message, null);
    }
  }
}
