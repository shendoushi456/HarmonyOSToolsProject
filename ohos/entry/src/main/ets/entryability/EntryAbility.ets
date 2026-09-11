
import { FlutterAbility, FlutterEngine } from '@ohos/flutter_ohos';
import { GeneratedPluginRegistrant } from '../plugins/GeneratedPluginRegistrant';
import TodoReminderPlugin from '../plugins/TodoReminderPlugin';
import CompassPlugin from '../plugins/CompassPlugin';
import PdfKitPlugin from '../plugins/PdfKitPlugin';
import DocumentGalleryPlugin from '../plugins/DocumentGalleryPlugin';
import CameraPermissionPlugin from '../plugins/CameraPermissionPlugin';

export default class EntryAbility extends FlutterAbility {
  private cameraPermissionPlugin?: CameraPermissionPlugin;

  configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    GeneratedPluginRegistrant.registerWith(flutterEngine)
    flutterEngine.getPlugins()?.add(new TodoReminderPlugin())
    flutterEngine.getPlugins()?.add(new CompassPlugin())
    // 注册自写 PDF Kit 原生插件(对齐 Android pic_toolslibrary/pdf/ 4 个 PDF Activity)
    flutterEngine.getPlugins()?.add(new PdfKitPlugin())
    // 注册系统相册保存插件(PDF转图片等结果批量写入照片库)
    flutterEngine.getPlugins()?.add(new DocumentGalleryPlugin(this.context))
    // 应用内相机预览前的运行时授权(图像处理页/扫描页共用)
    this.cameraPermissionPlugin = CameraPermissionPlugin.register(flutterEngine, this.context);
  }

  onDestroy(): void {
    this.cameraPermissionPlugin?.detach();
    super.onDestroy?.();
  }
}
