
import { FlutterAbility, FlutterEngine } from '@ohos/flutter_ohos';
import AbilityConstant from '@ohos.app.ability.AbilityConstant';
import Want from '@ohos.app.ability.Want';
import { GeneratedPluginRegistrant } from '../plugins/GeneratedPluginRegistrant';
import TodoReminderPlugin from '../plugins/TodoReminderPlugin';
import CompassPlugin from '../plugins/CompassPlugin';

export default class EntryAbility extends FlutterAbility {
  private readonly reminderPlugin = new TodoReminderPlugin();

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    super.onCreate(want, launchParam);
    this.reminderPlugin.handleReminderWant(want);
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    super.onNewWant(want, launchParam);
    this.reminderPlugin.handleReminderWant(want);
  }

  configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    GeneratedPluginRegistrant.registerWith(flutterEngine)
    this.reminderPlugin.setUiContext(this.context)
    flutterEngine.getPlugins()?.add(this.reminderPlugin)
    flutterEngine.getPlugins()?.add(new CompassPlugin())
  }
}
