import webview from '@ohos.web.webview';
import { PlatformView } from '@ohos/flutter_ohos';

@Observed
export declare class Params {
  direction: Direction;
  platformView: PlatformView;
}

/** 项目内的最小 ArkWeb PlatformView，仅用于展示协议链接。 */
export class PolicyWebView extends PlatformView {
  private readonly url: string;
  private readonly controller: webview.WebviewController = new webview.WebviewController();

  constructor(url: string) {
    super();
    this.url = url;
  }

  getType(): string {
    return 'web';
  }

  getView(): WrappedBuilder<[Params]> {
    return new WrappedBuilder(PolicyWebViewBuilder);
  }

  dispose(): void {
    this.controller.stopAllMedia();
  }

  getUrl(): string {
    return this.url;
  }

  getController(): webview.WebviewController {
    return this.controller;
  }
}

@Component
struct PolicyWebViewContent {
  @ObjectLink params: Params;
  private view: PolicyWebView = this.params.platformView as PolicyWebView;
  private controller: webview.WebviewController = this.view.getController();

  build() {
    Web({ src: this.view.getUrl(), controller: this.controller })
      .javaScriptAccess(true)
      .domStorageAccess(true)
      .mixedMode(MixedMode.All)
      .onControllerAttached(() => {
        this.controller.loadUrl(this.view.getUrl());
      });
  }
}

@Builder
export function PolicyWebViewBuilder(params: Params) {
  PolicyWebViewContent({ params: params });
}
