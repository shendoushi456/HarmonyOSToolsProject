
import { FlutterAbility, FlutterEngine } from '@ohos/flutter_ohos';
import { GeneratedPluginRegistrant } from '../plugins/GeneratedPluginRegistrant';
import CompassPlugin from '../plugins/CompassPlugin';
import LocationPlugin from '../plugins/LocationPlugin';

export default class EntryAbility extends FlutterAbility {
  configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    GeneratedPluginRegistrant.registerWith(flutterEngine)
    flutterEngine.getPlugins()?.add(new CompassPlugin())
    flutterEngine.getPlugins()?.add(new LocationPlugin())
  }
}
