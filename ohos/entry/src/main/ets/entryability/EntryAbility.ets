
import { FlutterAbility, FlutterEngine } from '@ohos/flutter_ohos';
import { GeneratedPluginRegistrant } from '../plugins/GeneratedPluginRegistrant';
import TodoReminderPlugin from '../plugins/TodoReminderPlugin';
import CompassPlugin from '../plugins/CompassPlugin';

export default class EntryAbility extends FlutterAbility {
  configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    GeneratedPluginRegistrant.registerWith(flutterEngine)
    flutterEngine.getPlugins()?.add(new TodoReminderPlugin())
    flutterEngine.getPlugins()?.add(new CompassPlugin())
  }
}
