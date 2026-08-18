import common from '@ohos.app.ability.common';
import { FlutterPage } from '@ohos/flutter_ohos';

const EVENT_BACK_PRESS = 'EVENT_BACK_PRESS';

let storage = LocalStorage.getShared();

@Entry(storage)
@Component
struct Index {
  private context = getContext(this) as common.UIAbilityContext;
  @LocalStorageLink('viewId') viewId: string = '';

  build() {
    Column() {
      FlutterPage({ viewId: this.viewId });
    }
  }

  onBackPress(): boolean {
    this.context.eventHub.emit(EVENT_BACK_PRESS);
    return true;
  }
}
