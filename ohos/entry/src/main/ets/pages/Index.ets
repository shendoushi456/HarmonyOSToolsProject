
import common from '@ohos.app.ability.common';
import { FlutterPage } from '@ohos/flutter_ohos'
import SecureGallerySaveCoordinator, { SecureGallerySaveOverlay } from '../plugins/SecureGallerySaveCoordinator';

let storage = LocalStorage.getShared()
const EVENT_BACK_PRESS = 'EVENT_BACK_PRESS'

@Entry(storage)
@Component
struct Index {
  private context = getContext(this) as common.UIAbilityContext
  @LocalStorageLink('viewId') viewId: string = "";
  @State private showGallerySaveOverlay: boolean = false;

  aboutToAppear(): void {
    SecureGallerySaveCoordinator.setListener((visible: boolean): void => {
      this.showGallerySaveOverlay = visible;
    });
  }

  aboutToDisappear(): void {
    SecureGallerySaveCoordinator.clearListener();
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      FlutterPage({ viewId: this.viewId })
        .width('100%')
        .height('100%');
      if (this.showGallerySaveOverlay) {
        SecureGallerySaveOverlay();
      }
    }
    .width('100%')
    .height('100%');
  }

  onBackPress(): boolean {
    this.context.eventHub.emit(EVENT_BACK_PRESS)
    return true
  }
}
