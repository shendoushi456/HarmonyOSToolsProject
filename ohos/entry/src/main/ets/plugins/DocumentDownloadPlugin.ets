import { BusinessError } from '@ohos.base';
import common from '@ohos.app.ability.common';
import { fileIo, fileUri, picker } from '@kit.CoreFileKit';
import MethodChannel, { MethodResult } from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodChannel';
import { FlutterEngine, MethodCall } from '@ohos/flutter_ohos';

const CHANNEL_NAME = 'hm.ruisi.saosaole/document_download';

/**
 * 将 Flutter 下载好的翻译文档保存到系统下载目录。
 *
 * DocumentPickerMode.DOWNLOAD 会将文件保存到 Download/包名/，并授予应用
 * 对返回 URI 的持久化访问权限，无需申请额外的存储权限。
 */
export default class DocumentDownloadPlugin {
  private channel?: MethodChannel;
  private context?: common.UIAbilityContext;

  static register(
    flutterEngine: FlutterEngine,
    context: common.UIAbilityContext,
  ): DocumentDownloadPlugin {
    const plugin = new DocumentDownloadPlugin();
    plugin.attach(flutterEngine, context);
    return plugin;
  }

  attach(flutterEngine: FlutterEngine, context: common.UIAbilityContext): void {
    const messenger = flutterEngine.dartExecutor.getBinaryMessenger();
    this.context = context;
    this.channel = new MethodChannel(messenger, CHANNEL_NAME);
    this.channel.setMethodCallHandler({
      onMethodCall: (call: MethodCall, result: MethodResult): void => {
        if (call.method === 'saveToDownloads') {
          this.saveToDownloads(call, result);
          return;
        }
        result.notImplemented();
      },
    });
  }

  detach(): void {
    this.channel?.setMethodCallHandler(null);
    this.channel = undefined;
    this.context = undefined;
  }

  private async saveToDownloads(
    call: MethodCall,
    result: MethodResult,
  ): Promise<void> {
    try {
      const fileName = call.argument('fileName') as string;
      const bytes = call.argument('bytes') as Uint8Array;
      if (!fileName || !bytes || bytes.byteLength === 0) {
        result.error('invalid_arguments', '缺少待保存的文件名或文件内容', null);
        return;
      }
      if (fileName.includes('/') || fileName.includes('\\')) {
        result.error('invalid_arguments', '文件名不能包含路径分隔符', null);
        return;
      }
      const context = this.context;
      if (!context) {
        result.error('not_attached', '保存插件尚未初始化', null);
        return;
      }

      const saveOptions = new picker.DocumentSaveOptions();
      saveOptions.pickerMode = picker.DocumentPickerMode.DOWNLOAD;
      const documentViewPicker = new picker.DocumentViewPicker(context);
      const uris = await documentViewPicker.save(saveOptions);
      if (uris.length === 0 || !uris[0]) {
        result.error('user_cancelled', '用户取消了保存到下载目录', null);
        return;
      }

      const directoryUri = uris[0].endsWith('/') ? uris[0].slice(0, -1) : uris[0];
      const targetUri = `${directoryUri}/${fileName}`;
      const targetPath = new fileUri.FileUri(targetUri).path;
      const file = fileIo.openSync(
        targetPath,
        fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.TRUNC,
      );
      try {
        fileIo.writeSync(file.fd, bytes.buffer);
        fileIo.fsyncSync(file.fd);
      } finally {
        fileIo.closeSync(file);
      }
      result.success(targetUri);
    } catch (error) {
      const businessError = error as BusinessError;
      const detail = businessError?.message ?? String(error);
      result.error(
        'save_to_downloads_failed',
        `保存到下载目录失败：code=${businessError?.code ?? 'unknown'}，${detail}`,
        null,
      );
    }
  }
}
