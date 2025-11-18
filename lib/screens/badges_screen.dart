import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BadgesScreen extends StatelessWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Blue Header Section
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
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Achievements',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header section
                  Text(
                    'Your Progress',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Track your learning journey and unlock achievements',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Progress Overview
                  const Text(
                    'Progress Overview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          icon: Icons.stars,
                          title: 'Badges Earned',
                          value: '0',
                          color: Colors.amber,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          icon: Icons.trending_up,
                          title: 'Total Points',
                          value: '0',
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Badges Section Title
                  Text(
                    'All Achievements',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Empty state message
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.emoji_events_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Start learning to earn your first badge!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Complete modules and quizzes to unlock achievements',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Show all badges as locked
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      _buildBadgeCard(
                        icon: Icons.code,
                        title: 'HTML Novice',
                        description: 'Complete HTML basics',
                        isEarned: false,
                        color: Colors.orange,
                      ),
                      _buildBadgeCard(
                        icon: Icons.javascript,
                        title: 'JavaScript Adept',
                        description: 'Master JavaScript fundamentals',
                        isEarned: false,
                        color: Colors.yellow[700]!,
                      ),
                      _buildBadgeCard(
                        icon: Icons.dataset,
                        title: 'Database Pro',
                        description: 'Complete database module',
                        isEarned: false,
                        color: Colors.blue,
                      ),
                      _buildBadgeCard(
                        icon: Icons.api,
                        title: 'API Master',
                        description: 'Build RESTful APIs',
                        isEarned: false,
                        color: Colors.purple,
                      ),
                      _buildBadgeCard(
                        icon: Icons.design_services,
                        title: 'UI Designer',
                        description: 'Create beautiful interfaces',
                        isEarned: false,
                        color: Colors.pink,
                      ),
                      _buildBadgeCard(
                        icon: Icons.security,
                        title: 'Security Expert',
                        description: 'Learn security best practices',
                        isEarned: false,
                        color: Colors.red,
                      ),
                      _buildBadgeCard(
                        icon: Icons.cloud,
                        title: 'Cloud Wizard',
                        description: 'Deploy to cloud platforms',
                        isEarned: false,
                        color: Colors.cyan,
                      ),
                      _buildBadgeCard(
                        icon: Icons.speed,
                        title: 'Performance Guru',
                        description: 'Optimize application performance',
                        isEarned: false,
                        color: Colors.green,
                      ),
                      _buildBadgeCard(
                        icon: Icons.auto_awesome,
                        title: 'AI Pioneer',
                        description: 'Integrate AI features',
                        isEarned: false,
                        color: Colors.indigo,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Milestones - Empty state
                  const Text(
                    'Recent Milestones',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.emoji_events_outlined,
                          color: const Color(0xFF2c6894),
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Your learning milestones will appear here as you progress',
                            style: GoogleFonts.poppins(
                              color: Colors.grey[600],
                              fontSize: 14,
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
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeCard({
    required IconData icon,
    required String title,
    required String description,
    required bool isEarned,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isEarned
            ? color.withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEarned
              ? color.withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isEarned
                  ? color.withValues(alpha: 0.2)
                  : Colors.grey.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isEarned ? color : Colors.grey,
              size: 32,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isEarned ? color : Colors.grey,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isEarned)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Icon(
                Icons.verified,
                color: color,
                size: 16,
              ),
            ),
        ],
      ),
    );
  }
}
