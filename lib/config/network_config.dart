import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Network configuration for different platforms and devices
class NetworkConfig {
  // IMPORTANT: Change this to your computer's IP address if testing on a physical device
  // Find your IP: Windows (ipconfig), Mac/Linux (ifconfig)
  static const String physicalDeviceIP = '192.168.1.9';
  
  // Set this to true if testing on a physical Android/iOS device
  static const bool usePhysicalDevice = false;
  
  // Backend server port
  static const String port = '3000';
  
  /// Get the appropriate base URL for the current platform
  static String get baseUrl {
    if (usePhysicalDevice) {
      // Physical device: use computer's local IP
      return 'http://$physicalDeviceIP:$port/api';
    }
    
    if (kIsWeb) {
      // Web: use localhost
      return 'http://localhost:$port/api';
    } else if (Platform.isAndroid) {
      // Android Emulator: use 10.0.2.2 (special alias for host machine)
      return 'http://10.0.2.2:$port/api';
    } else if (Platform.isIOS) {
      // iOS Simulator: use localhost
      return 'http://localhost:$port/api';
    } else {
      // Desktop (Windows, macOS, Linux): use localhost
      return 'http://localhost:$port/api';
    }
  }
  
  /// Get the base URL without /api suffix (for image URLs)
  static String get baseUrlWithoutApi {
    return baseUrl.replaceAll('/api', '');
  }
  
  /// Print current network configuration (for debugging)
  static void printConfig() {
    print('🌐 Network Configuration:');
    print('   Platform: ${_getPlatformName()}');
    print('   Mode: ${usePhysicalDevice ? "Physical Device" : "Emulator/Simulator"}');
    print('   Base URL: $baseUrl');
    print('   Physical Device IP: $physicalDeviceIP');
    print('');
  }
  
  static String _getPlatformName() {
    if (kIsWeb) return 'Web';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isLinux) return 'Linux';
    return 'Unknown';
  }
}
