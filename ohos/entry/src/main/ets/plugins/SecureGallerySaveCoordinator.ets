const GALLERY_EXPORT_ERROR = 'GALLERY_EXPORT_ERROR';
const GALLERY_SAVE_CANCELED = 'GALLERY_SAVE_CANCELED';
const GALLERY_SAVE_IN_PROGRESS = 'GALLERY_SAVE_IN_PROGRESS';
const GALLERY_SAVE_UI_UNAVAILABLE = 'GALLERY_SAVE_UI_UNAVAILABLE';

export class GallerySaveError extends Error {
  code: string;

  constructor(code: string, message: string) {
    super(message);
    this.code = code;
  }
}

type SaveAction = () => Promise<void>;
type SaveUiListener = (visible: boolean) => void;

interface PendingSaveRequest {
  action: SaveAction;
  resolve: () => void;
  reject: (error: GallerySaveError) => void;
}

/**
 * Flutter 插件与入口 ArkUI 页面之间的保存请求协调器。
 *
 * SaveButton 必须存在于真正的 ArkUI 组件树中。插件只创建请求并等待结果；
 * Index 页面接到通知后展示原生 SaveButton，按钮回调再执行真正的写相册操作。
 */
class SecureGallerySaveCoordinator {
  private pending?: PendingSaveRequest;
  private listener?: SaveUiListener;

  setListener(listener: SaveUiListener): void {
    this.listener = listener;
    listener(this.pending !== undefined);
  }

  clearListener(): void {
    this.listener = undefined;
  }

  request(action: SaveAction): Promise<void> {
    if (this.pending) {
      return Promise.reject(new GallerySaveError(
        GALLERY_SAVE_IN_PROGRESS,
        '正在等待保存确认，请勿重复操作',
      ));
    }
    if (!this.listener) {
      return Promise.reject(new GallerySaveError(
        GALLERY_SAVE_UI_UNAVAILABLE,
        '保存确认界面尚未准备好，请稍后重试',
      ));
    }

    return new Promise<void>((resolve, reject) => {
      this.pending = { action, resolve, reject };
      this.notify(true);
    });
  }

  /** 仅从原生 SaveButton 的成功回调调用。 */
  async confirm(): Promise<void> {
    const request = this.pending;
    if (!request) return;

    try {
      await request.action();
      this.complete(request);
    } catch (error) {
      this.fail(request, this.asGalleryError(error));
    }
  }

  cancel(): void {
    const request = this.pending;
    if (!request) return;
    this.fail(request, new GallerySaveError(GALLERY_SAVE_CANCELED, '已取消保存'));
  }

  rejectAuthorization(message: string): void {
    const request = this.pending;
    if (!request) return;
    this.fail(request, new GallerySaveError(GALLERY_EXPORT_ERROR, message));
  }

  private complete(request: PendingSaveRequest): void {
    if (this.pending !== request) return;
    this.pending = undefined;
    this.notify(false);
    request.resolve();
  }

  private fail(request: PendingSaveRequest, error: GallerySaveError): void {
    if (this.pending !== request) return;
    this.pending = undefined;
    this.notify(false);
    request.reject(error);
  }

  private notify(visible: boolean): void {
    this.listener?.(visible);
  }

  private asGalleryError(error: Object): GallerySaveError {
    if (error instanceof GallerySaveError) return error;
    const message = (error as Error)?.message || String(error);
    return new GallerySaveError(GALLERY_EXPORT_ERROR, `保存到系统相册失败：${message}`);
  }
}

const secureGallerySaveCoordinator = new SecureGallerySaveCoordinator();
export default secureGallerySaveCoordinator;

/** 必须由 Index 页面直接渲染，不能从 FlutterPlugin 中创建弹窗控制器。 */
@Component
export struct SecureGallerySaveOverlay {
  @State private saving: boolean = false;

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#66000000');

      Column({ space: 16 }) {
        Text('保存到系统相册')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor('#182431');
        Text('请点击下方系统“保存到相册”按钮确认保存。系统仅会授予本次保存所需的临时权限。')
          .fontSize(14)
          .fontColor('#5A6673')
          .lineHeight(20)
          .textAlign(TextAlign.Center);
        if (this.saving) {
          LoadingProgress()
            .width(28)
            .height(28)
            .color('#477AFF');
        } else {
          SaveButton({
            icon: SaveIconStyle.FULL_FILLED,
            text: SaveDescription.SAVE_TO_GALLERY,
            buttonType: ButtonType.Capsule,
          })
            .width('100%')
            .onClick(async (_event, saveResult, error) => {
              if (saveResult !== SaveButtonOnClickResult.SUCCESS) {
                secureGallerySaveCoordinator.rejectAuthorization(
                  error?.message ?? '未获得本次保存所需的临时授权',
                );
                return;
              }
              this.saving = true;
              await secureGallerySaveCoordinator.confirm();
            });
        }
        Button('取消')
          .fontColor('#5A6673')
          .backgroundColor(Color.Transparent)
          .onClick(() => secureGallerySaveCoordinator.cancel());
      }
      .width('82%')
      .padding(24)
      .borderRadius(20)
      .backgroundColor(Color.White);
    }
    .width('100%')
    .height('100%');
  }
}
