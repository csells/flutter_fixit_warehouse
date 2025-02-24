import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class PlatformUtil {
  static bool? _isIosSimulator;

  static final isDesktop = switch (defaultTargetPlatform) {
    TargetPlatform.macOS ||
    TargetPlatform.windows ||
    TargetPlatform.linux => true,
    _ => false,
  };

  static bool isAndroid = defaultTargetPlatform == TargetPlatform.android;

  static Future<void> init() async {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      _isIosSimulator = false;
    } else {
      final deviceInfo = DeviceInfoPlugin();
      final iosInfo = await deviceInfo.iosInfo;
      _isIosSimulator = !iosInfo.isPhysicalDevice;
    }
  }

  static bool get isIosSimulator {
    if (_isIosSimulator == null) {
      throw Exception('PlatformUtil.init must be called first');
    }

    return _isIosSimulator!;
  }
}
