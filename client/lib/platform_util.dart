import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class PlatformUtil {
  static bool? _isIosSimulator;
  static bool? _isAndroidEmulator;

  static final isDesktop = switch (defaultTargetPlatform) {
    TargetPlatform.macOS ||
    TargetPlatform.windows ||
    TargetPlatform.linux => true,
    _ => false,
  };

  static Future<void> init() async {
    final deviceInfo = DeviceInfoPlugin();

    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidInfo = await deviceInfo.androidInfo;
      _isAndroidEmulator = !androidInfo.isPhysicalDevice;
    } else {
      _isAndroidEmulator = false;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final iosInfo = await deviceInfo.iosInfo;
      _isIosSimulator = !iosInfo.isPhysicalDevice;
    } else {
      _isIosSimulator = false;
    }
  }

  static bool get isIosSimulator {
    if (_isIosSimulator == null) {
      throw Exception('PlatformUtil.init must be called first');
    }

    return _isIosSimulator!;
  }

  static bool get isAndroidEmulator {
    if (_isAndroidEmulator == null) {
      throw Exception('PlatformUtil.init must be called first');
    }

    return _isAndroidEmulator!;
  }

  static bool get isVirtualDevice => isIosSimulator || isAndroidEmulator;
}
