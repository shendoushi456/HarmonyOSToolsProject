import path from 'path'
import { appTasks } from '@ohos/hvigor-ohos-plugin';
import { flutterHvigorPlugin } from 'flutter-hvigor-plugin';

export default {
  system: appTasks, /* Built-in plugin of Hvigor. It cannot be modified. */
  plugins: [flutterHvigorPlugin(path.dirname(__dirname))] /* 引入 Flutter 构建插件，自动注入 @ohos/flutter_ohos 依赖 */
}