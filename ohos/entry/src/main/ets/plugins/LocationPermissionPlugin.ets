import {
  abilityAccessCtrl,
  bundleManager,
  common,
  PermissionRequestResult,
  Permissions,
} from '@kit.AbilityKit';
import {
  AbilityAware,
  AbilityPluginBinding,
  FlutterPlugin,
  FlutterPluginBinding,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult,
} from '@ohos/flutter_ohos';

const CHANNEL_NAME: string = 'bus/location_permission';
const CHECK_LOCATION_PERMISSION: string = 'checkLocationPermission';
const REQUEST_LOCATION_PERMISSION: string = 'requestLocationPermission';
const GET_APP_IDENTIFIER: string = 'getAppIdentifier';
const GET_RUNTIME_IDENTITY: string = 'getRuntimeIdentity';
const LOCATION_PERMISSIONS: Array<Permissions> = [
  'ohos.permission.LOCATION',
  'ohos.permission.APPROXIMATELY_LOCATION',
];

/** Bridges foreground location permission checks and requests to Flutter. */
export default class LocationPermissionPlugin implements
  FlutterPlugin,
  MethodCallHandler,
  AbilityAware {
  private channel: MethodChannel | null = null;
  private context: common.Context | null = null;

  getUniqueClassName(): string {
    return 'LocationPermissionPlugin';
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.channel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL_NAME);
    this.channel.setMethodCallHandler(this);
    // 插件挂载时立即打印一次，避免必须等到定位失败后才触发诊断调用。
    this.printRuntimeIdentity();
  }

  private async printRuntimeIdentity(): Promise<void> {
    try {
      const bundleInfo = await bundleManager.getBundleInfoForSelf(
        bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_SIGNATURE_INFO,
      );
      const bundleName = bundleInfo.name;
      const signatureInfo = bundleInfo.signatureInfo;
      const appId = signatureInfo?.appId ?? '';
      const fingerprint = signatureInfo?.fingerprint ?? '';
      const appIdentifier = signatureInfo?.appIdentifier ?? '';
      console.info(
        '[BaiduLocation] runtime identity: ' +
          `bundleName=${bundleName}, appId=${appId}, ` +
          `fingerprint=${fingerprint}, appIdentifier=${appIdentifier}`,
      );
    } catch (error) {
      console.error(`[BaiduLocation] runtime identity failed: ${JSON.stringify(error)}`);
    }
  }

  onDetachedFromEngine(_binding: FlutterPluginBinding): void {
    this.channel?.setMethodCallHandler(null);
    this.channel = null;
  }

  onAttachedToAbility(binding: AbilityPluginBinding): void {
    this.context = binding.getAbility().context;
  }

  onDetachedFromAbility(): void {
    this.context = null;
  }

  async onMethodCall(call: MethodCall, result: MethodResult): Promise<void> {
    try {
      if (call.method === CHECK_LOCATION_PERMISSION) {
        result.success(await this.hasLocationPermission());
        return;
      }
      if (call.method === REQUEST_LOCATION_PERMISSION) {
        result.success(await this.requestLocationPermission());
        return;
      }
      if (call.method === GET_APP_IDENTIFIER) {
        result.success(await this.getAppIdentifier());
        return;
      }
      if (call.method === GET_RUNTIME_IDENTITY) {
        result.success(await this.getRuntimeIdentity());
        return;
      }
      result.notImplemented();
    } catch (error) {
      console.error(`Location permission request failed: ${JSON.stringify(error)}`);
      result.success(false);
    }
  }

  private async hasLocationPermission(): Promise<boolean> {
    let tokenId: number = 0;
    try {
      const bundleInfo = await bundleManager.getBundleInfoForSelf(
        bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION,
      );
      tokenId = bundleInfo.appInfo.accessTokenId;
    } catch (error) {
      console.error(`Unable to read application token: ${JSON.stringify(error)}`);
      return false;
    }

    const atManager = abilityAccessCtrl.createAtManager();
    for (const permission of LOCATION_PERMISSIONS) {
      const status = await atManager.checkAccessToken(tokenId, permission);
      if (status !== abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        return false;
      }
    }
    return true;
  }

  /** 返回系统从当前安装 HAP 签名解析出的 AppID。 */
  private async getAppIdentifier(): Promise<string> {
    const identity = await this.getRuntimeIdentity();
    return String(identity.get('appIdentifier') ?? '');
  }

  /** 返回当前安装 HAP 的运行时签名身份，用于核对百度鸿蒙 AK。 */
  private async getRuntimeIdentity(): Promise<Map<string, string>> {
    const identity = new Map<string, string>();
    identity.set('bundleName', '');
    identity.set('appId', '');
    identity.set('fingerprint', '');
    identity.set('appIdentifier', '');
    try {
      const bundleInfo = await bundleManager.getBundleInfoForSelf(
        bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_SIGNATURE_INFO,
      );
      const signatureInfo = bundleInfo.signatureInfo;
      identity.set('bundleName', bundleInfo.name ?? '');
      identity.set('appId', signatureInfo?.appId ?? '');
      identity.set('fingerprint', signatureInfo?.fingerprint ?? '');
      identity.set('appIdentifier', signatureInfo?.appIdentifier ?? '');
      console.info(
        '[BaiduLocation] getRuntimeIdentity: ' +
          `bundleName=${identity.get('bundleName')}, appId=${identity.get('appId')}, ` +
          `fingerprint=${identity.get('fingerprint')}, ` +
          `appIdentifier=${identity.get('appIdentifier')}`,
      );
    } catch (error) {
      console.error(`getRuntimeIdentity failed. Cause: ${JSON.stringify(error)}`);
    }
    return identity;
  }

  private async requestLocationPermission(): Promise<boolean> {
    if (await this.hasLocationPermission()) {
      return true;
    }
    const context = this.context;
    if (context === null) {
      return false;
    }

    const atManager = abilityAccessCtrl.createAtManager();
    const requestResult: PermissionRequestResult =
      await atManager.requestPermissionsFromUser(context, LOCATION_PERMISSIONS);
    return requestResult.authResults.length === LOCATION_PERMISSIONS.length &&
      requestResult.authResults.every((authResult: number) => authResult === 0);
  }
}
