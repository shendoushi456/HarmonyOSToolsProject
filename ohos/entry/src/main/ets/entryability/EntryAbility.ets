import { FlutterAbility, FlutterEngine } from '@ohos/flutter_ohos';
import { GeneratedPluginRegistrant } from '../plugins/GeneratedPluginRegistrant';
import WifiPlugin from '../plugins/WifiPlugin';
import PdfKitPlugin from '../plugins/PdfKitPlugin';
import CameraPermissionPlugin from '../plugins/CameraPermissionPlugin';
import DocumentGalleryPlugin from '../plugins/DocumentGalleryPlugin';

export default class EntryAbility extends FlutterAbility {
  private cameraPermissionPlugin?: CameraPermissionPlugin;

  configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    // 注册 pub 依赖的插件
    GeneratedPluginRegistrant.registerWith(flutterEngine)
    // 注册自写 WiFi 原生插件(对齐 Android WifiManager/TrafficStats)
    flutterEngine.getPlugins()?.add(new WifiPlugin());
    // 注册自写 PDF Kit 原生插件(对齐 Android pic_toolslibrary/pdf/)
    flutterEngine.getPlugins()?.add(new PdfKitPlugin());
    flutterEngine.getPlugins()?.add(new DocumentGalleryPlugin(this.context));
    // 相机权限插件采用手动 MethodChannel 注册，不属于 FlutterPlugin 列表。
    this.cameraPermissionPlugin = CameraPermissionPlugin.register(
      flutterEngine,
      this.context,
    );
  }

  onDestroy(): void {
    this.cameraPermissionPlugin?.detach();
    super.onDestroy?.();
  }
}
