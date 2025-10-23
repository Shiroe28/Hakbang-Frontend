import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import '../providers/user_provider.dart';
import 'careers_screen.dart';
import 'profile_screen.dart';
import 'recommendation_quiz_screen.dart';
import 'community_screen.dart';
import 'notifications_screen.dart';
import 'help_support_screen.dart';
import 'badges_screen.dart';
import 'ai_chatbot_screen.dart';
import 'resume_builder_screen.dart';

class MainScreen extends StatefulWidget {
  final String role;

  const MainScreen({super.key, required this.role});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  String? _username;

  @override
  void initState() {
    super.initState();
    // Load user data after build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  Future<void> _loadUserData() async {
    // Load from UserProvider (which loads from API)
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.loadCurrentUser();
    
    // Get username from provider or storage
    String? username;
    if (userProvider.user != null) {
      username = userProvider.user!.username;
      
      // Save to storage for quick access next time
      await StorageService.saveAuthData(
        token: await StorageService.getToken() ?? '',
        role: widget.role,
        username: username,
      );
    } else {
      // Fallback to stored username if API fails
      username = await StorageService.getUsername();
    }
    
    if (mounted) {
      setState(() {
        _username = username;
      });
    }
  }

  void _navigateToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // List of screens for each tab
  List<Widget> get _screens => [
        HomeTabScreen(
          role: widget.role,
          username: _username,
          onNavigateToTab: _navigateToTab,
        ),
        const CareersScreen(),
        const CommunityScreen(),
        const ProfileScreen(),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey[600],
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_rounded),
            label: 'Careers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.forum_rounded),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// Home/Dashboard Tab
class HomeTabScreen extends StatelessWidget {
  final String role;
  final String? username;
  final Function(int)? onNavigateToTab;

  const HomeTabScreen({
    super.key,
    required this.role,
    this.username,
    this.onNavigateToTab,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hakbang'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                  child: Icon(
                    role == 'student'
                        ? Icons.school_rounded
                        : Icons.workspace_premium_rounded,
                    size: 30,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back${username != null ? ", $username" : ""}!',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: role == 'student'
                              ? Colors.blue[100]
                              : Colors.purple[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          role == 'student' ? 'Student' : 'Mentor',
                          style: TextStyle(
                            color: role == 'student'
                                ? Colors.blue[900]
                                : Colors.purple[900],
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Quick Stats or Info Cards
            Text(
              'Your Journey',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Info Cards
            _buildInfoCard(
              context,
              icon: Icons.explore_rounded,
              title: 'Explore Careers',
              description: 'Discover IT career paths that match your interests',
              color: Colors.blue,
              onTap: () {
                // Navigate to Careers tab
                onNavigateToTab?.call(1);
              },
            ),
            const SizedBox(height: 12),

            _buildInfoCard(
              context,
              icon: Icons.school_rounded,
              title: 'Learning Modules',
              description: 'Follow structured learning paths to achieve your goals',
              color: Colors.green,
              onTap: () {
                // Navigate to Careers tab (index 1) where modules are shown
                onNavigateToTab?.call(1);
              },
            ),
            const SizedBox(height: 12),

            _buildInfoCard(
              context,
              icon: Icons.quiz_rounded,
              title: 'AI Career Recommendations',
              description: 'Take a quiz to get personalized career suggestions',
              color: Colors.orange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RecommendationQuizScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            _buildInfoCard(
              context,
              icon: Icons.emoji_events_rounded,
              title: 'Achievements & Badges',
              description: 'Track your progress and earn badges',
              color: Colors.amber,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BadgesScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            _buildInfoCard(
              context,
              icon: Icons.smart_toy_rounded,
              title: 'AI Career Mentor',
              description: 'Chat with AI for career guidance and advice',
              color: Colors.indigo,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AIChatbotScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            _buildInfoCard(
              context,
              icon: Icons.description_rounded,
              title: 'AI Resume Builder',
              description: 'Get AI-powered feedback on your resume',
              color: Colors.teal,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ResumeBuilderScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            _buildInfoCard(
              context,
              icon: Icons.notifications_rounded,
              title: 'Notifications',
              description: 'Stay updated with latest news and updates',
              color: Colors.purple,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            _buildInfoCard(
              context,
              icon: Icons.help_rounded,
              title: 'Help & Support',
              description: 'Get help and find answers to your questions',
              color: Colors.teal,
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
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
