import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import '../providers/user_provider.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String role;

  const DashboardScreen({super.key, required this.role});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? _username;
  String? _email;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    // If UserProvider already has user, prefer that; otherwise fallback to storage
    final provider = Provider.of<UserProvider>(context, listen: false);
    if (provider.user != null) {
      setState(() {
        _username = provider.user!.username;
        _email = provider.user!.email;
      });
      return;
    }

    final username = await StorageService.getUsername();
    final email = await StorageService.getEmail();
    setState(() {
      _username = username;
      _email = email;
    });
  }

  Future<void> _handleLogout() async {
    final provider = Provider.of<UserProvider>(context, listen: false);
    provider.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_username != null
            ? 'Welcome back, ${_username!}!' : 'Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Welcome Icon
              Icon(
                widget.role == 'student'
                    ? Icons.school_rounded
                    : Icons.workspace_premium_rounded,
                size: 100,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 24),

              // Welcome Message
              Text(
                'Welcome to Hakbang!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // User Info Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Role Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: widget.role == 'student'
                              ? Colors.blue[100]
                              : Colors.purple[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.role == 'student' ? 'STUDENT' : 'MENTOR',
                          style: TextStyle(
                            color: widget.role == 'student'
                                ? Colors.blue[900]
                                : Colors.purple[900],
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Username
                      if (_username != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.person, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              _username!,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 8),

                      // Email
                      if (_email != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.email, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              _email!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Info Text
              Text(
                widget.role == 'student'
                    ? 'You are logged in as a Student.\nExplore IT careers and start learning!'
                    : 'You are logged in as a Mentor.\nHelp students achieve their goals!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Coming Soon Note
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber[300]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.amber[900]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'More features coming soon!',
                        style: TextStyle(
                          color: Colors.amber[900],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
