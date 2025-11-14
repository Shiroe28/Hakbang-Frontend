import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/storage_service.dart';
import '../providers/user_provider.dart';
import 'careers_screen.dart';
import 'profile_screen.dart';
import 'community_screen.dart';
import 'recommendation_quiz_screen.dart';
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
        selectedLabelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 12,
        ),
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
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Blue Header Section with HAKBANG logo
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF2c6894), // Azure blue
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 25),
            child: Column(
              children: [
                // HAKBANG Text with Glow Effect and Lifted Appearance
                Text(
                  'HAKBANG',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF5A9CC5), // Lighter blue - lifted color
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                    shadows: [
                      Shadow(
                        color: const Color(0xFF5A9CC5).withOpacity(0.8),
                        blurRadius: 15,
                        offset: const Offset(0, 2),
                      ),
                      Shadow(
                        color: Colors.white.withOpacity(0.5),
                        blurRadius: 25,
                        offset: const Offset(0, 1),
                      ),
                      Shadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: const Color(0xFF2c6894).withOpacity(0.1),
                            child: const Icon(
                              Icons.person,
                              size: 28,
                              color: Color(0xFF2c6894),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome back${username != null ? ", $username" : ""}!',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2c6894),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    role == 'student' ? 'Student' : 'Mentor',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Your Journey Section Title
                    Text(
                      'Your Journey',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Menu Items Cards - 8 total (scrollable)
                    _buildMenuCard(
                      context,
                      icon: Icons.explore_rounded,
                      title: 'Explore Careers',
                      description: 'Discover IT career paths that match your interests',
                      onTap: () {
                        // Navigate to Careers tab
                        onNavigateToTab?.call(1);
                      },
                    ),
                    const SizedBox(height: 12),

                    _buildMenuCard(
                      context,
                      icon: Icons.school_rounded,
                      title: 'Learning Modules',
                      description: 'Follow structured learning paths to achieve your goals',
                      onTap: () {
                        // Navigate to Careers tab (index 1) where modules are shown
                        onNavigateToTab?.call(1);
                      },
                    ),
                    const SizedBox(height: 12),

                    _buildMenuCard(
                      context,
                      icon: Icons.psychology_rounded,
                      title: 'AI Career Reccomendations',
                      description: 'Take a quiz to get personalized career suggestions',
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

                    _buildMenuCard(
                      context,
                      icon: Icons.emoji_events_rounded,
                      title: 'Achievements & Badges',
                      description: 'Track your progress and earn badges',
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

                    _buildMenuCard(
                      context,
                      icon: Icons.smart_toy_rounded,
                      title: 'AI Career Mentor',
                      description: 'Chat with AI for career guidance and advice',
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

                    _buildMenuCard(
                      context,
                      icon: Icons.description_rounded,
                      title: 'AI Resume Builder',
                      description: 'Get AI-powered feedback on your resume',
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

                    _buildMenuCard(
                      context,
                      icon: Icons.notifications_rounded,
                      title: 'Notifications',
                      description: 'Stay updated with latest news and updates',
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

                    _buildMenuCard(
                      context,
                      icon: Icons.help_rounded,
                      title: 'Help & Support',
                      description: 'Get help and find answers to your questions',
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 28, color: Colors.black),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
