import abilityAccessCtrl, { PermissionRequestResult, Permissions } from '@ohos.abilityAccessCtrl';
import bundleManager from '@ohos.bundle.bundleManager';
import { BusinessError } from '@ohos.base';
import common from '@ohos.app.ability.common';
import MethodChannel, { MethodResult } from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodChannel';
import { FlutterEngine, MethodCall } from '@ohos/flutter_ohos';
import Log from '@ohos/flutter_ohos/src/main/ets/util/Log';

const TAG = 'CameraPermissionPlugin';
const CHANNEL_NAME = 'hm.ruisi.saosaole/camera_permission';
const CAMERA_PERMISSION: Permissions = 'ohos.permission.CAMERA';

/**
 * 将相机权限的查询及申请交给应用侧处理。
 *
 * camera_ohos 会在 CameraController.initialize 时自行申请权限；页面需要在
 * 用户按下“拍照”后才触发申请，因此先通过这个通道完成授权再初始化相机。
 */
export default class CameraPermissionPlugin {
  private channel?: MethodChannel;
  private context?: common.UIAbilityContext;

  static register(flutterEngine: FlutterEngine, context: common.UIAbilityContext): CameraPermissionPlugin {
    const plugin = new CameraPermissionPlugin();
    plugin.attach(flutterEngine, context);
    return plugin;
  }

  attach(flutterEngine: FlutterEngine, context: common.UIAbilityContext): void {
    this.context = context;
    const messenger = flutterEngine.dartExecutor.getBinaryMessenger();
    this.channel = new MethodChannel(messenger, CHANNEL_NAME);
    this.channel.setMethodCallHandler({
      onMethodCall: (call: MethodCall, result: MethodResult): void => {
        if (call.method === 'requestCameraPermission') {
          this.requestCameraPermission(result);
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

  private async requestCameraPermission(result: MethodResult): Promise<void> {
    if (!this.context) {
      result.error('no_context', '无法获取应用上下文', null);
      return;
    }

    try {
      const atManager = abilityAccessCtrl.createAtManager();
      const bundleInfo = await bundleManager.getBundleInfoForSelf(
        bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION
      );
      const grantStatus = await atManager.checkAccessToken(
        bundleInfo.appInfo.accessTokenId,
        CAMERA_PERMISSION
      );
      if (grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        result.success(true);
        return;
      }

      const permissionResult: PermissionRequestResult = await atManager.requestPermissionsFromUser(
        this.context,
        [CAMERA_PERMISSION]
      );
      result.success(permissionResult.authResults.length > 0 && permissionResult.authResults[0] === 0);
    } catch (error) {
      const businessError = error as BusinessError;
      Log.e(TAG, `request camera permission failed: ${businessError.code}, ${businessError.message}`);
      result.error('camera_permission_failed', businessError.message, null);
    }
  }
}
