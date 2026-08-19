// FlutterAudioPlugin.ets
// 有道翻译 TTS 音频播放插件（鸿蒙侧实现）
//
// 对应原 Android `AudioMgr` + `PlayMgr`（MediaPlayer），改用鸿蒙 AVPlayer。
// 通过 MethodChannel 与 Flutter 侧 `AudioPlayerService` 通信。
//
// MethodChannel 名：com.hnrs.saolaisao/audio
// 方法：
//   - play(url: string)：开始播放
//   - stop()：停止播放
// 回调（native → Flutter）：
//   - onPlayOver：播放完成
//   - onError(message: string)：播放错误
//
// 注意：需在 DevEco Studio 中编译验证 API 细节（BinaryMessenger 获取方式等）。

import MethodChannel, { MethodResult } from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodChannel';
import { FlutterEngine, MethodCall } from '@ohos/flutter_ohos';
import { BusinessError } from '@ohos.base';
import media from '@ohos.multimedia.media';
import Log from '@ohos/flutter_ohos/src/main/ets/util/Log';

const TAG = 'FlutterAudioPlugin';
const CHANNEL_NAME = 'com.hnrs.saolaisao/audio';

export default class FlutterAudioPlugin {
  private channel?: MethodChannel;
  private avPlayer?: media.AVPlayer;

  /// 静态注册方法，供 EntryAbility 调用
  static register(flutterEngine: FlutterEngine): FlutterAudioPlugin {
    const plugin = new FlutterAudioPlugin();
    plugin.attach(flutterEngine);
    return plugin;
  }

  /// 绑定到 FlutterEngine，注册 MethodChannel
  attach(flutterEngine: FlutterEngine): void {
    const messenger = flutterEngine.dartExecutor.getBinaryMessenger();
    this.channel = new MethodChannel(messenger, CHANNEL_NAME);
    this.channel.setMethodCallHandler({
      onMethodCall: (call: MethodCall, result: MethodResult): void => {
        switch (call.method) {
          case 'play':
            this.handlePlay(call, result);
            break;
          case 'stop':
            this.handleStop(result);
            break;
          default:
            result.notImplemented();
        }
      }
    });
    Log.d(TAG, 'attach: channel registered');
  }

  /// 解绑
  detach(): void {
    if (this.avPlayer) {
      this.avPlayer.release();
      this.avPlayer = undefined;
    }
    if (this.channel) {
      this.channel.setMethodCallHandler(null);
      this.channel = undefined;
    }
    Log.d(TAG, 'detach: channel unregistered');
  }

  private async handlePlay(call: MethodCall, result: MethodResult): Promise<void> {
    const url: string = call.argument('url') as string;
    if (!url || !url.startsWith('http')) {
      result.error('invalid_url', '无效的音频URL', null);
      return;
    }

    try {
      // 停止当前播放
      if (this.avPlayer) {
        await this.avPlayer.release();
        this.avPlayer = undefined;
      }

      const player = await media.createAVPlayer();
      this.avPlayer = player;

      player.on('stateChange', async (state: string, reason: media.StateChangeReason) => {
        Log.d(TAG, `stateChange: ${state}`);
        switch (state) {
          case 'idle':
            await player.prepare();
            break;
          case 'prepared':
            await player.play();
            result.success(null);
            break;
          case 'completed':
            Log.d(TAG, '播放完成');
            this.invokeCallback('onPlayOver', null);
            break;
          case 'released':
            break;
          default:
            break;
        }
      });

      player.on('error', (err: BusinessError) => {
        Log.e(TAG, `播放错误: ${JSON.stringify(err)}`);
        this.invokeCallback('onError', '播放错误');
      });

      // 设置 URL 触发状态机
      player.url = url;
    } catch (e) {
      Log.e(TAG, `handlePlay failed: ${JSON.stringify(e)}`);
      result.error('play_failed', '播放失败', e);
    }
  }

  private async handleStop(result: MethodResult): Promise<void> {
    try {
      if (this.avPlayer) {
        await this.avPlayer.release();
        this.avPlayer = undefined;
      }
      result.success(null);
    } catch (e) {
      Log.e(TAG, `handleStop failed: ${JSON.stringify(e)}`);
      result.error('stop_failed', '停止失败', e);
    }
  }

  /// 回调 Flutter 侧
  private invokeCallback(method: string, args: object | string | null): void {
    if (this.channel) {
      this.channel.invokeMethod(method, args);
    }
  }
}
