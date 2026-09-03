import abilityAccessCtrl, { PermissionRequestResult, Permissions } from '@ohos.abilityAccessCtrl';
import bundleManager from '@ohos.bundle.bundleManager';
import { BusinessError } from '@ohos.base';
import common from '@ohos.app.ability.common';
import MethodChannel, { MethodResult } from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodChannel';
import { FlutterEngine, MethodCall } from '@ohos/flutter_ohos';
import Log from '@ohos/flutter_ohos/src/main/ets/util/Log';

const TAG = 'CameraPermissionPlugin';
const CHANNEL_NAME = 'toolbox.camera/permission';
const CAMERA_PERMISSION: Permissions = 'ohos.permission.CAMERA';

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
}
