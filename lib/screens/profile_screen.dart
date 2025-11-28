import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import '../providers/user_provider.dart';
import '../config/network_config.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';
import 'notifications_screen.dart';
import 'help_support_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _username;
  String? _email;
  String? _role;
  String? _profilePicture;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Load from API if not already loaded
    if (userProvider.user == null) {
      await userProvider.loadCurrentUser();
    }

    // Use data from UserProvider if available
    if (userProvider.user != null) {
      print('🖼️ ProfileScreen - Loading user data from provider');
      print('🖼️ ProfileScreen - Profile Picture: ${userProvider.user!.profilePicture}');
      setState(() {
        _username = userProvider.user!.username;
        _email = userProvider.user!.email;
        _role = userProvider.user!.role;
        _profilePicture = userProvider.user!.profilePicture;
        _isLoading = false;
      });
      return;
    }

    // Fallback to storage if API fails
    final username = await StorageService.getUsername();
    final email = await StorageService.getEmail();
    final role = await StorageService.getRole();

    setState(() {
      _username = username;
      _email = email;
      _role = role;
      _isLoading = false;
    });
  }

  Future<void> _handleLogout() async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await StorageService.clearAuthData();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  /// Get role badge background color
  Color _getRoleBadgeColor(String? role) {
    if (role?.toLowerCase() == 'admin') {
      return Colors.red[100]!;
    }
    return Colors.blue[100]!; // Student (default)
  }

  /// Get role badge text color
  Color _getRoleBadgeTextColor(String? role) {
    if (role?.toLowerCase() == 'admin') {
      return Colors.red[900]!;
    }
    return Colors.blue[900]!; // Student (default)
  }

  /// Get role badge display text (uppercase)
  String _getRoleBadgeText(String? role) {
    if (role?.toLowerCase() == 'admin') {
      return 'ADMIN';
    }
    return 'STUDENT'; // Default
  }

  /// Get role display name (title case)
  String _getRoleDisplayName(String? role) {
    if (role?.toLowerCase() == 'admin') {
      return 'Admin';
    }
    return 'Student'; // Default
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Listen to UserProvider for live updates
    final userProvider = Provider.of<UserProvider>(context);
    final profilePic = userProvider.user?.profilePicture ?? _profilePicture;
    final displayRole = userProvider.user?.role ?? _role;
    final displayUsername = userProvider.user?.username ?? _username;
    final displayEmail = userProvider.user?.email ?? _email;
    
    print('🖼️ ProfileScreen build - profilePic: $profilePic');
    if (profilePic != null && profilePic.isNotEmpty) {
      print('🖼️ ProfileScreen - Full URL: ${NetworkConfig.baseUrlWithoutApi}$profilePic');
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header (matches main screen style with rounded corners)
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF2c6894),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            child: Text(
              'PROFILE',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                shadows: [
                  Shadow(
                    color: Colors.white.withOpacity(0.5),
                    blurRadius: 8,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Profile Avatar
                  CircleAvatar(
                    radius: 60,
                    backgroundColor:
                        Theme.of(context).primaryColor.withValues(alpha: 0.2),
                    backgroundImage: profilePic != null && profilePic.isNotEmpty
                        ? NetworkImage(
                            '${NetworkConfig.baseUrlWithoutApi}$profilePic')
                        : null,
                    child: profilePic == null || profilePic.isEmpty
                        ? Icon(
                            displayRole == 'student'
                                ? Icons.school_rounded
                                : Icons.workspace_premium_rounded,
                            size: 60,
                            color: Theme.of(context).primaryColor,
                          )
                        : null,
                  ),
                  const SizedBox(height: 24),

                  // Username
                  Text(
                    displayUsername ?? 'User',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),

                  // Role Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _getRoleBadgeColor(displayRole),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getRoleBadgeText(displayRole),
                      style: TextStyle(
                        color: _getRoleBadgeTextColor(displayRole),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Profile Information Card
                  Card(
                    elevation: 2,
                    child: Column(
                      children: [
                        _buildInfoTile(
                          icon: Icons.person_rounded,
                          title: 'Username',
                          value: displayUsername ?? 'N/A',
                        ),
                        const Divider(height: 1),
                        _buildInfoTile(
                          icon: Icons.email_rounded,
                          title: 'Email',
                          value: displayEmail ?? 'N/A',
                        ),
                        const Divider(height: 1),
                        _buildInfoTile(
                          icon: Icons.badge_rounded,
                          title: 'Role',
                          value: _getRoleDisplayName(displayRole),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Settings Options
                  Card(
                    elevation: 2,
                    child: Column(
                      children: [
                        _buildActionTile(
                          icon: Icons.edit_rounded,
                          title: 'Edit Profile',
                          onTap: () async {
                            final userProvider = Provider.of<UserProvider>(
                                context,
                                listen: false);

                            // Show loading dialog
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );

                            try {
                              // Always reload user to get latest data
                              print('🔄 Reloading user data for edit profile...');
                              await userProvider.loadCurrentUser();

                              // Close loading dialog
                              if (mounted) Navigator.pop(context);

                              // Check if user is loaded
                              if (userProvider.user != null) {
                                print('✅ User loaded: ${userProvider.user!.username}');
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditProfileScreen(
                                        user: userProvider.user!),
                                  ),
                                );
                                // Reload user data if profile was updated
                                if (result == true) {
                                  _loadUserData();
                                }
                              } else {
                                print('❌ User is still null after loading');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Failed to load user data. Please try logging in again.'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            } catch (e) {
                              print('❌ Error loading user: $e');
                              // Close loading dialog
                              if (mounted) Navigator.pop(context);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: ${e.toString()}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                        ),
                        const Divider(height: 1),
                        _buildActionTile(
                          icon: Icons.notifications_rounded,
                          title: 'Notifications',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const NotificationsScreen(),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        _buildActionTile(
                          icon: Icons.help_rounded,
                          title: 'Help & Support',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HelpSupportScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _handleLogout,
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // App Version
                  Text(
                    'Hakbang v1.0.0',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey[400],
      ),
      onTap: onTap,
    );
  }
}
