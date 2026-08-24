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
import abilityAccessCtrl, { Permissions } from '@ohos.abilityAccessCtrl';
import geoLocationManager from '@ohos.geoLocationManager';
import UIAbility from '@ohos.app.ability.UIAbility';

const CHANNEL = 'com.p.a_b/toolbox_location';
const LOCATION_PERMISSION: Permissions = 'ohos.permission.LOCATION';
const APPROXIMATE_PERMISSION: Permissions = 'ohos.permission.APPROXIMATELY_LOCATION';

/// 原生定位桥接。
///
/// 使用 OpenHarmony 系统定位和逆地理编码，避免把 Android 百度 SDK 与密钥迁入鸿蒙工程。
export default class LocationPlugin implements FlutterPlugin, AbilityAware, MethodCallHandler {
  private channel: MethodChannel | null = null;
  private ability: UIAbility | null = null;

  getUniqueClassName(): string {
    return 'ToolboxLocationPlugin';
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.channel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL);
    this.channel.setMethodCallHandler(this);
  }

  onDetachedFromEngine(_: FlutterPluginBinding): void {
    this.channel?.setMethodCallHandler(null);
    this.channel = null;
  }

  onAttachedToAbility(binding: AbilityPluginBinding): void {
    this.ability = binding.getAbility();
  }

  onDetachedFromAbility(): void {
    this.ability = null;
  }

  async onMethodCall(call: MethodCall, result: MethodResult): Promise<void> {
    if (call.method !== 'getCurrentLocation' && call.method !== 'requestCurrentLocation') {
      result.notImplemented();
      return;
    }
    if (this.ability === null) {
      result.error('location_unavailable', '定位需要前台页面', null);
      return;
    }

    try {
      if (call.method === 'requestCurrentLocation') {
        await this.requestLocationPermission();
      }
      if (!await this.hasLocationPermission()) {
        result.error('location_permission_denied', '请允许位置权限以获取海拔和坐标', null);
        return;
      }
      const location = await geoLocationManager.getCurrentLocation({
        priority: geoLocationManager.LocationRequestPriority.ACCURACY,
        timeoutMs: 15000,
      });
      const address = await this.resolveAddress(location.latitude, location.longitude);
      result.success({
        latitude: location.latitude,
        longitude: location.longitude,
        altitude: location.altitude,
        address: address,
      });
    } catch (error) {
      if (String(error).indexOf('location_permission_denied') >= 0) {
        result.error('location_permission_denied', '请允许位置权限以获取海拔和坐标', error);
      } else {
        result.error('location_failed', '无法获取当前位置，请检查定位服务后重试', error);
      }
    }
  }

  private async requestLocationPermission(): Promise<void> {
    if (this.ability === null) return;
    const manager = abilityAccessCtrl.createAtManager();
    const response = await manager.requestPermissionsFromUser(this.ability.context, [
      APPROXIMATE_PERMISSION,
      LOCATION_PERMISSION,
    ]);
    if (response.authResults.indexOf(0) < 0) {
      throw new Error('location_permission_denied');
    }
  }

  private async hasLocationPermission(): Promise<boolean> {
    if (this.ability === null) return false;
    const manager = abilityAccessCtrl.createAtManager();
    const tokenId = this.ability.context.applicationInfo.accessTokenId;
    const precise = await manager.checkAccessToken(tokenId, LOCATION_PERMISSION);
    const approximate = await manager.checkAccessToken(tokenId, APPROXIMATE_PERMISSION);
    return precise === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED ||
      approximate === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;
  }

  private async resolveAddress(latitude: number, longitude: number): Promise<string> {
    try {
      const addresses = await geoLocationManager.getAddressesFromLocation({
        latitude: latitude,
        longitude: longitude,
        locale: 'zh',
        maxItems: 1,
      });
      if (addresses.length === 0) return '';
      const address = addresses[0];
      return address.addressUrl ?? address.placeName ?? address.locality ?? '';
    } catch (_) {
      return '';
    }
  }
}
