import common from '@ohos.app.ability.common';
import { PlatformView, PlatformViewFactory, StandardMessageCodec } from '@ohos/flutter_ohos';
import { PolicyWebView } from './PolicyWebView';

/** 将 Flutter 的 creationParams 转成 ArkWeb PlatformView。 */
export class PolicyWebViewFactory extends PlatformViewFactory {
  constructor() {
    super(StandardMessageCodec.INSTANCE);
  }

  create(context: common.Context, viewId: number, args: ESObject): PlatformView {
    let url = 'about:blank';
    if (args instanceof Map) {
      const params: Map<string, string> = args as Map<string, string>;
      const value: string | undefined = params.get('url');
      if (value !== undefined && value.length > 0) {
        url = value;
      }
    }
    return new PolicyWebView(url);
  }
}
