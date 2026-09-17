import { FlutterAbility, FlutterEngine } from '@ohos/flutter_ohos';
import { GeneratedPluginRegistrant } from '../plugins/GeneratedPluginRegistrant';
import WifiPlugin from '../plugins/WifiPlugin';
import PdfKitPlugin from '../plugins/PdfKitPlugin';
import DocumentGalleryPlugin from '../plugins/DocumentGalleryPlugin';
import CameraPermissionPlugin from '../plugins/CameraPermissionPlugin';
import NotifySpeedPlugin from '../plugins/NotifySpeedPlugin';

export default class EntryAbility extends FlutterAbility {
  private cameraPermissionPlugin?: CameraPermissionPlugin;

  configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    // 注册 pub 依赖的插件
    GeneratedPluginRegistrant.registerWith(flutterEngine)
    // 注册自写 WiFi 原生插件(对齐 Android WifiManager/TrafficStats)
    flutterEngine.getPlugins()?.add(new WifiPlugin(this.context));
    // 注册自写 PDF Kit 原生插件(对齐 Android pic_toolslibrary/pdf/)
    flutterEngine.getPlugins()?.add(new PdfKitPlugin());
    // 保存扫描文档到系统相册。
    flutterEngine.getPlugins()?.add(new DocumentGalleryPlugin(this.context));
    // 应用内相机预览前的运行时授权。
    this.cameraPermissionPlugin = CameraPermissionPlugin.register(flutterEngine, this.context);
    // 常驻通知实时网速插件(对齐 Android NetworkSpeedService 简化版)
    flutterEngine.getPlugins()?.add(new NotifySpeedPlugin(this.context));
  }

  onDestroy(): void {
    this.cameraPermissionPlugin?.detach();
    super.onDestroy?.();
  }
}
