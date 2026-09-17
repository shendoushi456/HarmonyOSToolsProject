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

/**
 * 使用 SaveButton 的相册导出桥接。
 *
 * SaveButton 是系统安全组件：用户实际点击后，系统只为当前回调授予一次临时
 * 写入照片库的权限。因此不需要申请受限的 WRITE_IMAGEVIDEO ACL 权限。
 */
export default class DocumentGalleryPlugin implements FlutterPlugin {
  private readonly abilityContext: common.UIAbilityContext;
  private channel: MethodChannel | null = null;
  private saving = false;

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
    if (call.method === 'saveImageBytes') {
      this.handleSaveImageBytes(call, result);
      return;
    }
    if (call.method === 'saveImageBytesList') {
      this.handleSaveImageBytesList(call, result);
      return;
    }
    result.notImplemented();
  }

  /** 单张图片保存。 */
  private async handleSaveImageBytes(call: MethodCall, result: MethodResult): Promise<void> {
    if (this.saving) {
      result.error(GALLERY_SAVE_IN_PROGRESS, '正在等待保存确认，请勿重复操作', null);
      return;
    }

    try {
      const bytes = call.argument('bytes') as Uint8Array;
      const title = call.argument('name') as string;
      if (!bytes || bytes.byteLength === 0 || !title) {
        throw new GallerySaveError(GALLERY_EXPORT_ERROR, '缺少图片数据或保存名称');
      }
      this.saving = true;
      await this.requestSecureSave(bytes, title);
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

  /** 多张图片批量保存：一次 SaveButton 授权写入全部图片，避免逐张弹确认框。 */
  private async handleSaveImageBytesList(call: MethodCall, result: MethodResult): Promise<void> {
    if (this.saving) {
      result.error(GALLERY_SAVE_IN_PROGRESS, '正在等待保存确认，请勿重复操作', null);
      return;
    }

    try {
      const rawList: ESObject = call.argument('bytesList');
      const bytesList: Uint8Array[] = rawList as Uint8Array[];
      const title = call.argument('name') as string;
      if (!bytesList || bytesList.length === 0 || !title) {
        throw new GallerySaveError(GALLERY_EXPORT_ERROR, '缺少图片数据或保存名称');
      }
      this.saving = true;
      await this.requestSecureSaveList(bytesList, title);
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

  private async requestSecureSave(bytes: Uint8Array, title: string): Promise<void> {
    const safeTitle = this.safeTitle(title);
    await SecureGallerySaveCoordinator.request(async (): Promise<void> => {
      // 此回调由 Index 页面里真正可见的 SaveButton 成功回调直接触发。
      await this.writeImageWithTemporaryAuthorization(bytes, safeTitle);
    });
  }

  /** 批量保存：在同一个 SaveButton 授权回调内写入全部图片。 */
  private async requestSecureSaveList(bytesList: Uint8Array[], title: string): Promise<void> {
    const safeTitle = this.safeTitle(title);
    await SecureGallerySaveCoordinator.request(async (): Promise<void> => {
      for (let i = 0; i < bytesList.length; i++) {
        const name = bytesList.length === 1 ? safeTitle : `${safeTitle}_${i + 1}`;
        await this.writeImageWithTemporaryAuthorization(bytesList[i], name);
      }
    });
  }

  /** 只能从 SaveButton 成功回调中调用，临时授权在该回调结束后即失效。 */
  private async writeImageWithTemporaryAuthorization(bytes: Uint8Array, title: string): Promise<void> {
    let targetFile: fileIo.File | undefined;
    try {
      const helper = photoAccessHelper.getPhotoAccessHelper(this.abilityContext);
      const targetUri = await helper.createAsset(
        photoAccessHelper.PhotoType.IMAGE,
        'jpg',
        { title: title },
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
          // 已成功写入的文件不因关闭阶段的非关键异常被误报为失败。
        }
      }
    }
  }

  private safeTitle(title: string): string {
    return title.replace(/[\\/:*?"<>|]/g, '_').substring(0, 80) || '图片处理结果';
  }

  private describeError(error: Object): string {
    const message = (error as Error)?.message;
    return message || String(error);
  }
}
