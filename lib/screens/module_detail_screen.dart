import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/module_model.dart';
import 'module_assessment_screen.dart';
import '../services/api_service.dart';

class ModuleDetailScreen extends StatefulWidget {
  final Module module;

  const ModuleDetailScreen({super.key, required this.module});

  @override
  State<ModuleDetailScreen> createState() => _ModuleDetailScreenState();
}

class _ModuleDetailScreenState extends State<ModuleDetailScreen> {
  bool _isCompleting = false;
  late Module _module;

  @override
  void initState() {
    super.initState();
    _module = widget.module;
  }

  Future<void> _toggleCompletion() async {
    setState(() => _isCompleting = true);
    
    try {
      final isCurrentlyCompleted = _module.isCompleted;
      print('🎯 ${isCurrentlyCompleted ? "Unmarking" : "Marking"} module as complete: ${_module.id}');
      print('🎯 Career ID: ${_module.careerId}');
      
      final result = isCurrentlyCompleted
          ? await ApiService.markModuleIncomplete(
              _module.id,
              _module.careerId,
            )
          : await ApiService.markModuleComplete(
              _module.id,
              _module.careerId,
            );
      
      if (result['success'] == true) {
        setState(() {
          _module = _module.copyWith(isCompleted: !isCurrentlyCompleted);
          _isCompleting = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isCurrentlyCompleted 
                ? '🔄 Module marked as incomplete!'
                : '✅ Module marked as complete!'),
              backgroundColor: isCurrentlyCompleted ? Colors.orange : Colors.green,
            ),
          );
        }
        
        // Check if badge was earned (only when completing, not uncompleting)
        if (!isCurrentlyCompleted && result['badgeEarned'] == true && result['badge'] != null) {
          final badge = result['badge'];
          if (mounted) {
            _showAchievementDialog(
              title: badge['title'] ?? 'Achievement Unlocked!',
              description: badge['description'] ?? 'Great job!',
              icon: badge['icon'] ?? '🏆',
            );
            
            // Create notification for the earned badge
            await ApiService.createNotification(
              title: '🏆 New Badge Earned!',
              message: '${badge['icon']} ${badge['title']} - ${badge['description']}',
              type: 'badge',
            );
            
            // 🌟 Generate AI motivational reflection for badge earned (runs in background)
            ApiService.generateMotivationalReflection(
              milestoneType: 'badge_earned',
              milestoneName: badge['title'] ?? 'Achievement',
              additionalContext: {
                'badgeIcon': badge['icon'],
                'badgeDescription': badge['description'],
              },
            );
          }
        }
        
        // Create milestone notification when completing
        if (!isCurrentlyCompleted && mounted) {
          await ApiService.createNotification(
            title: '📚 Module Completed',
            message: 'Great job! You completed "${_module.title}"',
            type: 'milestone',
          );
          
          // 🌟 Generate AI motivational reflection and show popup
          final motivationalMessage = await ApiService.generateMotivationalReflection(
            milestoneType: 'module_completed',
            milestoneName: _module.title,
            additionalContext: {
              'moduleId': _module.id,
              'careerId': _module.careerId,
            },
          );
          
          // Show motivational popup if message was generated
          if (motivationalMessage != null && mounted) {
            // 🔄 Fallback: Create motivation notification from frontend
            // (in case backend doesn't create it automatically)
            await ApiService.createNotification(
              title: '✨ Smart Reflection',
              message: motivationalMessage,
              type: 'motivation',
            );
            
            // First show a quick SnackBar notification
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Text('✨', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    const Expanded(child: Text('You have a new motivational message!')),
                  ],
                ),
                backgroundColor: Colors.pink.shade400,
                duration: const Duration(seconds: 3),
                action: SnackBarAction(
                  label: 'View',
                  textColor: Colors.white,
                  onPressed: () => _showMotivationalPopup(motivationalMessage),
                ),
              ),
            );
            
            // Then show the full dialog after a short delay
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                _showMotivationalPopup(motivationalMessage);
              }
            });
          }
        }
      } else {
        setState(() => _isCompleting = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ ${result['message'] ?? "Failed to update module status"}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Error toggling completion: $e');
      setState(() => _isCompleting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAchievementDialog({
    required String title,
    required String description,
    required String icon,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade400, Colors.blue.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '🎉 Achievement Unlocked! 🎉',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.elasticOut,
                  builder: (context, double value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Text(
                        icon,
                        style: const TextStyle(fontSize: 80),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.purple,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Awesome!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMotivationalPopup(String message) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.pink.shade300, Colors.purple.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Sparkle icon with animation
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.elasticOut,
                  builder: (context, double value, child) {
                    return Transform.scale(
                      scale: value,
                      child: const Text(
                        '✨',
                        style: TextStyle(fontSize: 60),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Words of Encouragement',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.95),
                    fontSize: 16,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.pink.shade400,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Thank you! 💪',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _launchURL(BuildContext context) async {
    final url = Uri.parse(_module.contentURL);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open the link'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening link: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Module Details'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Module Header
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      _module.contentType == 'link'
                          ? Icons.link
                          : Icons.video_library,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    _module.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Content Type Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _module.contentType.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Module Content
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description Section
                  Text(
                    'About This Module',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _module.description,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Learning Resource Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.blue[200]!,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: Colors.blue[700],
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Learning Resource',
                                style: TextStyle(
                                  color: Colors.blue[900],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Click below to access the learning material',
                                style: TextStyle(
                                  color: Colors.blue[700],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Start Learning Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _launchURL(context),
                      icon: const Icon(Icons.open_in_new),
                      label: const Text(
                        'Start Learning',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Take Assessment Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ModuleAssessmentScreen(
                              moduleId: _module.id,
                              moduleName: _module.title,
                              careerId: _module.careerId,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.quiz),
                      label: const Text(
                        'Take Assessment',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Mark as Complete/Incomplete Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isCompleting ? null : _toggleCompletion,
                      icon: _isCompleting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(
                              _module.isCompleted ? Icons.check_circle : Icons.circle_outlined,
                            ),
                      label: Text(
                        _isCompleting
                            ? 'Saving...'
                            : _module.isCompleted
                                ? 'Mark as Incomplete'
                                : 'Mark as Complete',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        foregroundColor: _module.isCompleted ? Colors.green : null,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
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
