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

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 20.0 : 12.0,
          vertical: isSelected ? 12.0 : 10.0,
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2c6894) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  const BoxShadow(
                    color: Color(0x4D2c6894), // 30% opacity
                    blurRadius: 12,
                    spreadRadius: 0,
                    offset: Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFF757575),
              size: isSelected ? 26.0 : 24.0,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_rounded, 'Home'),
                _buildNavItem(1, Icons.work_rounded, 'Careers'),
                _buildNavItem(2, Icons.forum_rounded, 'Community'),
                _buildNavItem(3, Icons.person_rounded, 'Profile'),
              ],
            ),
          ),
        ),
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
          // Blue Header Section with HAKBANG logo and Notification Icon
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
            child: Stack(
              alignment: Alignment.center,
              children: [
                // HAKBANG Text centered
                Text(
                  'HAKBANG',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),
                // Notification Icon positioned on the right
                Positioned(
                  right: 0,
                  child: IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.notifications_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
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
                            backgroundColor:
                                const Color(0xFF2c6894).withOpacity(0.1),
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
                        fontSize: 22,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 2-Column Grid Layout
                    LayoutBuilder(
                      builder: (context, constraints) {
                        // Calculate card width based on screen size
                        double cardWidth = (constraints.maxWidth - 12) / 2;

                        return Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _buildGridCard(
                              context,
                              icon: Icons.explore_rounded,
                              title: 'Explore Careers',
                              description: 'Discover IT paths',
                              gradient: const LinearGradient(
                                colors: [Color(0xFF0FA3E2), Color(0xFF2DB3E8)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              width: cardWidth,
                              onTap: () {
                                onNavigateToTab?.call(1);
                              },
                            ),
                            _buildGridCard(
                              context,
                              icon: Icons.psychology_rounded,
                              title: 'AI Career Quiz',
                              description: 'Get personalized suggestions',
                              gradient: const LinearGradient(
                                colors: [Color(0xFF4597B8), Color(0xFF5BA7C3)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              width: cardWidth,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const RecommendationQuizScreen(),
                                  ),
                                );
                              },
                            ),
                            _buildGridCard(
                              context,
                              icon: Icons.emoji_events_rounded,
                              title: 'Achievements',
                              description: 'Track progress & badges',
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6AAFCA), Color(0xFF7EBDD4)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              width: cardWidth,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const BadgesScreen(),
                                  ),
                                );
                              },
                            ),
                            _buildGridCard(
                              context,
                              icon: Icons.smart_toy_rounded,
                              title: 'AI Mentor',
                              description: 'Chat for career guidance',
                              gradient: const LinearGradient(
                                colors: [Color(0xFF8FC7DC), Color(0xFFA0D1E4)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              width: cardWidth,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const AIChatbotScreen(),
                                  ),
                                );
                              },
                            ),
                            _buildGridCard(
                              context,
                              icon: Icons.description_rounded,
                              title: 'AI Feedback Resume',
                              description: 'AI-powered feedback',
                              gradient: const LinearGradient(
                                colors: [Color(0xFFB4DFED), Color(0xFFC2E5F1)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              width: cardWidth,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ResumeBuilderScreen(),
                                  ),
                                );
                              },
                            ),
                            _buildGridCard(
                              context,
                              icon: Icons.help_rounded,
                              title: 'Help & Support',
                              description: 'Find answers & help',
                              gradient: const LinearGradient(
                                colors: [Color(0xFF2C6894), Color(0xFF3D7BA5)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              width: cardWidth,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const HelpSupportScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
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

  Widget _buildGridCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Gradient gradient,
    required double width,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: 160,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: Colors.white,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.white,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
