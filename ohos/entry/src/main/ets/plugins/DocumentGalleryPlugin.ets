import {
  FlutterPlugin,
  FlutterPluginBinding,
  MethodCall,
  MethodChannel,
  MethodResult,
} from '@ohos/flutter_ohos';
import common from '@ohos.app.ability.common';
import { fileIo } from '@kit.CoreFileKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import SecureGallerySaveCoordinator, { GallerySaveError } from './SecureGallerySaveCoordinator';

const GALLERY_EXPORT_ERROR = 'GALLERY_EXPORT_ERROR';
const GALLERY_SAVE_IN_PROGRESS = 'GALLERY_SAVE_IN_PROGRESS';

// 将应用沙箱中的扫描图片导出到鸿蒙系统相册。
export default class DocumentGalleryPlugin implements FlutterPlugin {
  private readonly abilityContext: common.UIAbilityContext;
  private channel: MethodChannel | null = null;
  private saving: boolean = false;

  constructor(abilityContext: common.UIAbilityContext) {
    this.abilityContext = abilityContext;
  }

  getUniqueClassName(): string {
    return 'DocumentGalleryPlugin';
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.channel = new MethodChannel(binding.getBinaryMessenger(), 'toolbox.scan_documents/gallery');
    this.channel.setMethodCallHandler({
      onMethodCall: (call: MethodCall, result: MethodResult): void => {
        this.handleMethodCall(call, result);
      },
    });
  }

  onDetachedFromEngine(_binding: FlutterPluginBinding): void {
    this.channel?.setMethodCallHandler(null);
    this.channel = null;
  }

  private async handleMethodCall(call: MethodCall, result: MethodResult): Promise<void> {
    if (call.method !== 'saveImageBytes') {
      result.notImplemented();
      return;
    }
    if (this.saving) {
      result.error(GALLERY_SAVE_IN_PROGRESS, '正在等待保存确认，请勿重复操作', null);
      return;
    }

    try {
      const bytes: Uint8Array = call.argument('bytes') as Uint8Array;
      const title: string = call.argument('name') as string;
      if (!bytes || bytes.byteLength === 0 || !title) {
        throw new GallerySaveError(GALLERY_EXPORT_ERROR, '缺少图片数据或保存名称');
      }
      this.saving = true;
      await SecureGallerySaveCoordinator.request(async (): Promise<void> => {
        await this.writeImageWithTemporaryAuthorization(bytes, this.safeTitle(title));
      });
      result.success(null);
    } catch (error) {
      const exportError = error as GallerySaveError;
      result.error(
        exportError.code ?? GALLERY_EXPORT_ERROR,
        exportError.message ?? this.describeError(error),
        null,
      );
    } finally {
      this.saving = false;
    }
  }

  /** 只能从系统 SaveButton 成功回调中调用，此时拥有本次写图库的临时授权。 */
  private async writeImageWithTemporaryAuthorization(bytes: Uint8Array, title: string): Promise<void> {
    let targetFile: fileIo.File | undefined;
    try {
      const helper = photoAccessHelper.getPhotoAccessHelper(this.abilityContext);
      const targetUri = await helper.createAsset(
        photoAccessHelper.PhotoType.IMAGE,
        'jpg',
        { title },
      );
      targetFile = await fileIo.open(targetUri, fileIo.OpenMode.READ_WRITE);
      const written = await fileIo.write(targetFile.fd, bytes.buffer);
      if (written !== bytes.byteLength) {
        throw new GallerySaveError(GALLERY_EXPORT_ERROR, '图片数据写入不完整');
      }
    } catch (error) {
      if (error instanceof GallerySaveError) throw error;
      throw new GallerySaveError(
        GALLERY_EXPORT_ERROR,
        `保存到系统相册失败：${this.describeError(error)}`,
      );
    } finally {
      if (targetFile) {
        try {
          await fileIo.close(targetFile);
        } catch (_) {
          // 文件已写入时，关闭阶段的非关键异常不影响保存结果。
        }
      }
    }
  }

  private safeTitle(title: string): string {
    return title.replace(/[\\/:*?"<>|]/g, '_').substring(0, 80) || '文档扫描';
  }

  private describeError(error: Object): string {
    const message = (error as Error)?.message;
    return message || String(error);
  }
}
