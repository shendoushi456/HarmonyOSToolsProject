import { FlutterAbility, FlutterEngine } from '@ohos/flutter_ohos';
import AbilityConstant from '@ohos.app.ability.AbilityConstant';
import Want from '@ohos.app.ability.Want';
import { GeneratedPluginRegistrant } from '../plugins/GeneratedPluginRegistrant';
import WifiPlugin from '../plugins/WifiPlugin';
import PdfKitPlugin from '../plugins/PdfKitPlugin';
import DocumentGalleryPlugin from '../plugins/DocumentGalleryPlugin';
import CameraPermissionPlugin from '../plugins/CameraPermissionPlugin';
import TodoReminderPlugin from '../plugins/TodoReminderPlugin';

export default class EntryAbility extends FlutterAbility {
  private cameraPermissionPlugin?: CameraPermissionPlugin;
  private readonly reminderPlugin = new TodoReminderPlugin();

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    super.onCreate(want, launchParam);
    // 冷启动：缓存通知点击携带的定位参数
    this.reminderPlugin.handleReminderWant(want);
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    super.onNewWant(want, launchParam);
    // 热启动：直接回调 Flutter 侧 onReminderLaunch
    this.reminderPlugin.handleReminderWant(want);
  }

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
    // 待办/打卡系统提醒(ReminderAgent + 通知授权 + 通知点击跳转)
    this.reminderPlugin.setUiContext(this.context)
    flutterEngine.getPlugins()?.add(this.reminderPlugin)
  }

  onDestroy(): void {
    this.cameraPermissionPlugin?.detach();
    super.onDestroy?.();
  }
}
