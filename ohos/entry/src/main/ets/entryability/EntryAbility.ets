import { FlutterAbility, FlutterEngine } from '@ohos/flutter_ohos';
import { GeneratedPluginRegistrant } from '../plugins/GeneratedPluginRegistrant';
import WifiPlugin from '../plugins/WifiPlugin';

export default class EntryAbility extends FlutterAbility {
  configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    // 注册 pub 依赖的插件
    GeneratedPluginRegistrant.registerWith(flutterEngine)
    // 注册自写 WiFi 原生插件(对齐 Android WifiManager/TrafficStats)
    flutterEngine.getPlugins()?.add(new WifiPlugin());
  }
}
