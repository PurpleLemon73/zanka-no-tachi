import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum PresentationMode { mobile, tablet, tv }

abstract final class PresentationModePolicy {
  static PresentationMode resolve({
    required bool isTelevision,
    required bool isTablet,
  }) {
    if (isTelevision) return PresentationMode.tv;
    return isTablet ? PresentationMode.tablet : PresentationMode.mobile;
  }
}

class PresentationModeDetector {
  const PresentationModeDetector();

  static const _channel = MethodChannel('dev.zanka.notachi/device');

  Future<PresentationMode> detect() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return PresentationMode.mobile;
    }
    try {
      final result = await _channel.invokeMapMethod<String, Object?>(
        'presentationMode',
      );
      return PresentationModePolicy.resolve(
        isTelevision: result?['isTelevision'] == true,
        isTablet: result?['isTablet'] == true,
      );
    } on MissingPluginException {
      return PresentationMode.mobile;
    } on PlatformException {
      return PresentationMode.mobile;
    }
  }
}
