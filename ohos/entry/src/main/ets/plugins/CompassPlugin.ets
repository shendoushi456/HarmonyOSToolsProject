import {
  FlutterPlugin,
  FlutterPluginBinding,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult,
} from '@ohos/flutter_ohos';
import sensor from '@ohos.sensor';

const CHANNEL = 'com.p.a_b/toolbox_compass';

/** 将鸿蒙方向传感器数据提供给 Flutter 指南针页面。 */
export default class CompassPlugin implements FlutterPlugin {
  private methodChannel: MethodChannel | null = null;
  private heading: number = 0;
  private listening: boolean = false;

  private readonly onOrientation = (data: sensor.OrientationResponse): void => {
    this.heading = data.alpha;
  };

  getUniqueClassName(): string {
    return 'CompassPlugin';
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.methodChannel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL);
    this.methodChannel.setMethodCallHandler(this.methodCall);
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    this.stopListening();
    this.methodChannel?.setMethodCallHandler(null);
    this.methodChannel = null;
  }

  private methodCall: MethodCallHandler = {
    onMethodCall: (call: MethodCall, result: MethodResult): void => {
      switch (call.method) {
        case 'getHeading':
          this.startListening();
          result.success(this.heading);
          return;
        case 'stopHeading':
          this.stopListening();
          result.success(null);
          return;
        default:
          result.notImplemented();
      }
    },
  };

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
