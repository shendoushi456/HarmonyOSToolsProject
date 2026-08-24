import {
  FlutterPlugin,
  FlutterPluginBinding,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult,
} from '@ohos/flutter_ohos';
import sensor from '@ohos.sensor';

const CHANNEL = 'com.p.a_b/toolbox_heading';

/// 将鸿蒙方向传感器提供给 Flutter 的海拔和指南针页面。
export default class CompassPlugin implements FlutterPlugin, MethodCallHandler {
  private channel: MethodChannel | null = null;
  private heading: number = 0;
  private orientationBeta: number = 0;
  private orientationGamma: number = 0;
  private listening: boolean = false;

  private readonly onOrientation = (data: sensor.OrientationResponse): void => {
    this.heading = data.alpha;
    this.orientationBeta = data.beta;
    this.orientationGamma = data.gamma;
  };

  getUniqueClassName(): string {
    return 'ToolboxCompassPlugin';
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.channel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL);
    this.channel.setMethodCallHandler(this);
  }

  onDetachedFromEngine(_: FlutterPluginBinding): void {
    this.stopListening();
    this.channel?.setMethodCallHandler(null);
    this.channel = null;
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    if (call.method === 'getHeading') {
      try {
        this.startListening();
        result.success(this.heading);
      } catch (error) {
        result.error('heading_unavailable', '当前设备未提供方向传感器', error);
      }
      return;
    }
    if (call.method === 'getOrientation') {
      try {
        this.startListening();
        result.success({
          alpha: this.heading,
          beta: this.orientationBeta,
          gamma: this.orientationGamma,
        });
      } catch (error) {
        result.error('orientation_unavailable', '当前设备未提供姿态传感器', error);
      }
      return;
    }
    if (call.method === 'stopHeading') {
      this.stopListening();
      result.success(null);
      return;
    }
    result.notImplemented();
  }

  private startListening(): void {
    if (this.listening) return;
    sensor.on(sensor.SensorId.ORIENTATION, this.onOrientation);
    this.listening = true;
  }

  private stopListening(): void {
    if (!this.listening) return;
    sensor.off(sensor.SensorId.ORIENTATION, this.onOrientation);
    this.listening = false;
  }
}
