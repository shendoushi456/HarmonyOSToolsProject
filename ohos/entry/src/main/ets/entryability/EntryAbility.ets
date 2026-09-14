import { FlutterAbility, FlutterEngine } from '@ohos/flutter_ohos';
import { GeneratedPluginRegistrant } from '../plugins/GeneratedPluginRegistrant';
import DocumentUploadPlugin from '../plugins/DocumentUploadPlugin';
import CameraPermissionPlugin from '../plugins/CameraPermissionPlugin';
import DocumentDownloadPlugin from '../plugins/DocumentDownloadPlugin';
import PdfKitPlugin from '../plugins/PdfKitPlugin';
import DocumentGalleryPlugin from '../plugins/DocumentGalleryPlugin';

export default class EntryAbility extends FlutterAbility {
  private documentUploadPlugin?: DocumentUploadPlugin;
  private cameraPermissionPlugin?: CameraPermissionPlugin;
  private documentDownloadPlugin?: DocumentDownloadPlugin;

  configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    GeneratedPluginRegistrant.registerWith(flutterEngine)
    this.documentUploadPlugin = DocumentUploadPlugin.register(flutterEngine)
    this.cameraPermissionPlugin = CameraPermissionPlugin.register(flutterEngine, this.context)
    this.documentDownloadPlugin = DocumentDownloadPlugin.register(flutterEngine, this.context)
    // PDF Kit 原生通道（图片转PDF / PDF转图片）
    flutterEngine.getPlugins()?.add(new PdfKitPlugin());
    // 相册保存通道（SaveButton 安全组件，PDF转图片保存到相册）
    flutterEngine.getPlugins()?.add(new DocumentGalleryPlugin(this.context));
  }

  onDestroy(): void {
    this.documentUploadPlugin?.detach()
    this.cameraPermissionPlugin?.detach()
    this.documentDownloadPlugin?.detach()
    super.onDestroy?.()
  }
}
