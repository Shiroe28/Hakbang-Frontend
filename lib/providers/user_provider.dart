import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class UserProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;

  Future<void> loadCurrentUser() async {
    _isLoading = true;
    // Schedule notification for next frame to avoid calling during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      print('🔄 Loading user from /api/users/me or /api/auth/me...');
      final data = await ApiService.getMe();
      
      if (data != null) {
        print('✅ User data received: ${data['username'] ?? data['name']}');
        print('🖼️ ProfilePicture from API: ${data['profilePicture']}');
        _user = User.fromJson(Map<String, dynamic>.from(data));
        print('✅ User model created: ${_user?.username}');
        print('🖼️ User model profilePicture: ${_user?.profilePicture}');
      } else {
        print('⚠️ getMe() returned null - no user data');
        _user = null;
      }
    } catch (e) {
      print('❌ Failed to load user: $e');
      _user = null;
    }

    _isLoading = false;
    // Schedule notification for next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  void clear() async {
    _user = null;
    await StorageService.clearAuthData();
    notifyListeners();
  }
}
