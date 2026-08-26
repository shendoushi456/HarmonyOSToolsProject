import { FlutterPlugin, FlutterPluginBinding } from '@ohos/flutter_ohos';
import { PolicyWebViewFactory } from './PolicyWebViewFactory';

/** 在 Flutter 引擎中注册项目内置的策略页 WebView。 */
export class PolicyWebViewPlugin implements FlutterPlugin {
  getUniqueClassName(): string {
    return 'PolicyWebViewPlugin';
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    binding.getPlatformViewRegistry().registerViewFactory(
      'hm.lxhy.youyouxing/policy_webview',
      new PolicyWebViewFactory()
    );
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
  }
}
