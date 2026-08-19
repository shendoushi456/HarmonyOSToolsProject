import 'package:flutter/services.dart';

/// 音频播放服务
///
/// 对应原 Android `AudioMgr` + `PlayMgr`（MediaPlayer）。
/// 鸿蒙侧通过 MethodChannel 调用原生 AVPlayer 实现 URL 音频播放。
///
/// MethodChannel 名：`com.hnrs.saolaisao/audio`
/// 方法：
/// - `play`（参数 {url}）：开始播放
/// - `stop`：停止播放
/// 回调（native → Flutter）：
/// - `onPlayOver`：播放完成
/// - `onError`（参数 {message}）：播放错误
class AudioPlayerService {
  AudioPlayerService() {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  static const MethodChannel _channel =
      MethodChannel('com.hnrs.saolaisao/audio');

  VoidCallback? _onPlayOver;
  void Function(String error)? _onError;

  /// 播放语音
  ///
  /// [url] 音频 URL（http）
  /// [onPlayOver] 播放完成回调
  /// [onError] 播放错误回调
  Future<void> startPlayVoice(
    String? url, {
    VoidCallback? onPlayOver,
    void Function(String error)? onError,
  }) async {
    if (url == null || !url.startsWith('http')) {
      onError?.call('无效的音频URL');
      return;
    }
    _onPlayOver = onPlayOver;
    _onError = onError;
    try {
      await _channel.invokeMethod<void>('play', <String, dynamic>{'url': url});
    } on PlatformException catch (e) {
      onError?.call(e.message ?? '播放失败');
      _onPlayOver = null;
      _onError = null;
    } on MissingPluginException {
      // 鸿蒙侧未实现时的占位处理
      onError?.call('播放功能未实现');
      _onPlayOver = null;
      _onError = null;
    }
  }

  /// 停止播放
  Future<void> stop() async {
    try {
      await _channel.invokeMethod<void>('stop');
    } on PlatformException {
      // 忽略
    } on MissingPluginException {
      // 忽略
    }
    _onPlayOver = null;
    _onError = null;
  }

  /// 释放资源
  Future<void> release() async {
    await stop();
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onPlayOver':
        final callback = _onPlayOver;
        _onPlayOver = null;
        _onError = null;
        callback?.call();
      case 'onError':
        final callback = _onError;
        _onPlayOver = null;
        _onError = null;
        final message = call.arguments is String
            ? call.arguments as String
            : '播放错误';
        callback?.call(message);
    }
  }
}
