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

interface SaveImageArgs {
  sourcePath: string;
  name: string;
}

// 将应用沙箱中的扫描图片导出到鸿蒙系统相册。
export default class DocumentGalleryPlugin implements FlutterPlugin {
  private readonly abilityContext: common.UIAbilityContext;
  private channel: MethodChannel | null = null;

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
    try {
      if (call.method !== 'saveImage') {
        result.notImplemented();
        return;
      }
      const args: SaveImageArgs = call.args as SaveImageArgs;
      const sourcePath: string = args.sourcePath;
      const title: string = args.name;
      if (!sourcePath || !title) throw new Error('缺少图片或名称');

      const extension = this.extensionOf(sourcePath);
      const helper = photoAccessHelper.getPhotoAccessHelper(this.abilityContext);
      const targetUri = await helper.createAsset(
        photoAccessHelper.PhotoType.IMAGE,
        extension,
        { title: this.safeTitle(title) },
      );
      await fileIo.copyFile(sourcePath, targetUri);
      result.success(targetUri);
    } catch (error) {
      result.error('DOCUMENT_EXPORT_ERROR', (error as Error)?.message ?? String(error), null);
    }
  }

  private extensionOf(path: string): string {
    const index = path.lastIndexOf('.');
    const extension = index < 0 ? 'jpg' : path.substring(index + 1).toLowerCase();
    return extension === 'png' ? 'png' : 'jpg';
  }

  private safeTitle(title: string): string {
    return title.replace(/[\\/:*?"<>|]/g, '_').substring(0, 80) || '文档扫描';
  }
}
