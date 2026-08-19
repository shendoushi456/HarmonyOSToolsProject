import { FlutterAbility, FlutterEngine } from '@ohos/flutter_ohos';
import { GeneratedPluginRegistrant } from '../plugins/GeneratedPluginRegistrant';
import FlutterAudioPlugin from '../plugins/FlutterAudioPlugin';
import DocumentUploadPlugin from '../plugins/DocumentUploadPlugin';
import CameraPermissionPlugin from '../plugins/CameraPermissionPlugin';

export default class EntryAbility extends FlutterAbility {
  private audioPlugin?: FlutterAudioPlugin;
  private documentUploadPlugin?: DocumentUploadPlugin;
  private cameraPermissionPlugin?: CameraPermissionPlugin;

  configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    GeneratedPluginRegistrant.registerWith(flutterEngine)
    // 注册音频播放插件（TTS 朗读功能）
    this.audioPlugin = FlutterAudioPlugin.register(flutterEngine)
    this.documentUploadPlugin = DocumentUploadPlugin.register(flutterEngine)
    this.cameraPermissionPlugin = CameraPermissionPlugin.register(flutterEngine, this.context)
  }

  onDestroy(): void {
    // 释放音频资源
    this.audioPlugin?.detach()
    this.documentUploadPlugin?.detach()
    this.cameraPermissionPlugin?.detach()
    super.onDestroy?.()
  }
}
