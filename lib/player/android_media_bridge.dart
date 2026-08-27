import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum AndroidMediaCommand { play, pause, toggle, seekBackward, seekForward }

class AndroidMediaBridge {
  AndroidMediaBridge({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel('dev.zanka.notachi/media');

  final MethodChannel _channel;
  ValueChanged<AndroidMediaCommand>? onCommand;
  bool _available = defaultTargetPlatform == TargetPlatform.android;

  Future<void> activate({
    required String title,
    required String episode,
  }) async {
    if (!_available) return;
    _channel.setMethodCallHandler(_handleCall);
    await _invoke('activate', {'title': title, 'episode': episode});
  }

  Future<bool> requestAudioFocus() async {
    if (!_available) return true;
    final value = await _invoke('requestAudioFocus');
    return value != false;
  }

  Future<void> update({
    required bool playing,
    required Duration position,
    required Duration duration,
  }) async {
    await _invoke('update', {
      'playing': playing,
      'positionMs': position.inMilliseconds,
      'durationMs': duration.inMilliseconds,
    });
  }

  Future<void> deactivate() async {
    await _invoke('deactivate');
    _channel.setMethodCallHandler(null);
  }

  Future<Object?> _invoke(
    String method, [
    Map<String, Object?>? arguments,
  ]) async {
    if (!_available) return null;
    try {
      return await _channel.invokeMethod<Object?>(method, arguments);
    } on MissingPluginException {
      _available = false;
      return null;
    } on PlatformException {
      return null;
    }
  }

  Future<void> _handleCall(MethodCall call) async {
    final command = switch (call.method) {
      'play' => AndroidMediaCommand.play,
      'pause' || 'audioFocusLoss' => AndroidMediaCommand.pause,
      'toggle' => AndroidMediaCommand.toggle,
      'seekBackward' => AndroidMediaCommand.seekBackward,
      'seekForward' => AndroidMediaCommand.seekForward,
      _ => null,
    };
    if (command != null) onCommand?.call(command);
  }
}
