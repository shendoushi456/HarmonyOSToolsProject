import { FlutterAbility, FlutterEngine } from '@ohos/flutter_ohos';
import { GeneratedPluginRegistrant } from '../plugins/GeneratedPluginRegistrant';
import DocumentUploadPlugin from '../plugins/DocumentUploadPlugin';
import CameraPermissionPlugin from '../plugins/CameraPermissionPlugin';
import DocumentDownloadPlugin from '../plugins/DocumentDownloadPlugin';

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
  }

  onDestroy(): void {
    this.documentUploadPlugin?.detach()
    this.cameraPermissionPlugin?.detach()
    this.documentDownloadPlugin?.detach()
    super.onDestroy?.()
  }
}
