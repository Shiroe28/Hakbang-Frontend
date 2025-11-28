import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/career_model.dart';
import '../models/module_model.dart';
import '../services/api_service.dart';
import 'module_detail_screen.dart';

class CareerDetailScreen extends StatefulWidget {
  final Career career;

  const CareerDetailScreen({super.key, required this.career});

  @override
  State<CareerDetailScreen> createState() => _CareerDetailScreenState();
}

class _CareerDetailScreenState extends State<CareerDetailScreen> {
  List<Module> _modules = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadModules();
  }

  Future<void> _loadModules() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print(
          '🎯 CareerDetailScreen: Loading modules for career ID: "${widget.career.id}"');
      print('🎯 Career title: "${widget.career.title}"');
      
      // Fetch modules and user progress in parallel
      final modulesResponse = await ApiService.getModules(careerId: widget.career.id);
      final progressData = await ApiService.fetchUserProgress(widget.career.id);
      
      // Get completed module IDs from progress
      final List<dynamic> moduleProgress = progressData['moduleProgress'] ?? [];
      final Set<String> completedModuleIds = {};
      
      for (var progress in moduleProgress) {
        if (progress['completed'] == true) {
          final moduleId = progress['moduleId'];
          if (moduleId != null) {
            // Handle both string and object formats
            final moduleIdString = moduleId is String 
                ? moduleId 
                : moduleId['_id'] as String;
            completedModuleIds.add(moduleIdString);
            print('➕ Added completed module ID: $moduleIdString');
          }
        }
      }
      
      print('✅ Found ${completedModuleIds.length} completed modules');
      print('📋 Completed IDs: $completedModuleIds');
      
      // Mark modules as completed based on progress
      final updatedModules = modulesResponse.map((module) {
        final isCompleted = completedModuleIds.contains(module.id);
        print('📌 Module ${module.title}: ${isCompleted ? "✅ Completed" : "⭕ Not completed"}');
        return module.copyWith(isCompleted: isCompleted);
      }).toList();
      
      if (mounted) {
        setState(() {
          _modules = updatedModules;
          _isLoading = false;
        });
        print('✅ CareerDetailScreen: Loaded ${updatedModules.length} modules');
      }
    } catch (e) {
      print('❌ CareerDetailScreen: Error loading modules: $e');
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header (no rounded corners for careers)
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF2c6894),
            ),
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
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
                Expanded(
                  child: Text(
                    'HAKBANG',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(width: 48), // Balance the back button
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Career Header Section
                  _buildCareerHeader(),

                  const SizedBox(height: 8),

                  // Skills Required Section
                  _buildSkillsSection(),

                  // Learning Roadmap Section
                  _buildLearningRoadmap(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCareerHeader() {
    return Container(
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
            child: const Icon(
              Icons.work_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            widget.career.title,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            widget.career.description,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),

          // Salary Range
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.payments_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.career.salaryRange,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsSection() {
    // If no skills are available, show a placeholder
    if (!widget.career.hasSkills) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: Colors.grey[400],
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Skills information coming soon...',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            children: [
              Icon(
                Icons.psychology_rounded,
                color: Theme.of(context).primaryColor,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Skills Required',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${widget.career.skillCount} skills',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Master these skills to excel in this career',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          
          // Skills Grid
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.career.skillsRequired.map((skill) {
              return _buildSkillChip(skill);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillChip(String skill) {
    // Define colors for variety
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
      Colors.cyan,
    ];
    
    // Use skill's hash to consistently assign a color
    final colorIndex = skill.hashCode.abs() % colors.length;
    final color = colors[colorIndex];
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getSkillIcon(skill),
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            skill,
            style: TextStyle(
              color: color.shade700,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSkillIcon(String skill) {
    final skillLower = skill.toLowerCase();
    
    // Programming languages
    if (skillLower.contains('python')) return Icons.code;
    if (skillLower.contains('java')) return Icons.coffee;
    if (skillLower.contains('javascript') || skillLower.contains('js')) return Icons.javascript;
    if (skillLower.contains('html')) return Icons.html;
    if (skillLower.contains('css')) return Icons.css;
    if (skillLower.contains('sql')) return Icons.storage;
    if (skillLower.contains('c++') || skillLower.contains('c#')) return Icons.code;
    
    // Frameworks & Tools
    if (skillLower.contains('react') || skillLower.contains('angular') || skillLower.contains('vue')) return Icons.web;
    if (skillLower.contains('node')) return Icons.dns;
    if (skillLower.contains('flutter') || skillLower.contains('dart')) return Icons.phone_android;
    if (skillLower.contains('docker') || skillLower.contains('kubernetes')) return Icons.cloud;
    if (skillLower.contains('git')) return Icons.account_tree;
    if (skillLower.contains('aws') || skillLower.contains('azure') || skillLower.contains('cloud')) return Icons.cloud_queue;
    
    // Data & AI
    if (skillLower.contains('machine learning') || skillLower.contains('ml') || skillLower.contains('ai')) return Icons.psychology;
    if (skillLower.contains('data')) return Icons.analytics;
    if (skillLower.contains('database')) return Icons.storage;
    
    // Security & Network
    if (skillLower.contains('security') || skillLower.contains('cyber')) return Icons.security;
    if (skillLower.contains('network')) return Icons.hub;
    
    // Soft skills
    if (skillLower.contains('communication')) return Icons.chat;
    if (skillLower.contains('problem') || skillLower.contains('solving')) return Icons.lightbulb;
    if (skillLower.contains('team') || skillLower.contains('collaboration')) return Icons.groups;
    if (skillLower.contains('leadership')) return Icons.leaderboard;
    
    // Design
    if (skillLower.contains('ui') || skillLower.contains('ux') || skillLower.contains('design')) return Icons.design_services;
    if (skillLower.contains('figma') || skillLower.contains('photoshop')) return Icons.brush;
    
    // Default
    return Icons.star_rounded;
  }

  Widget _buildLearningRoadmap() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            children: [
              Icon(
                Icons.route_rounded,
                color: Theme.of(context).primaryColor,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Learning Roadmap',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Follow these modules to master this career path',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),

          // Modules List
          _buildModulesList(),
        ],
      ),
    );
  }

  Widget _buildModulesList() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load modules',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadModules,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_modules.isEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(
              Icons.school_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No modules available yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for learning content',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _modules.length,
      itemBuilder: (context, index) {
        final module = _modules[index];
        return _buildModuleCard(module, index + 1);
      },
    );
  }

  Widget _buildModuleCard(Module module, int moduleNumber) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: InkWell(
        onTap: () async {
          // Navigate to module detail and wait for result
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ModuleDetailScreen(module: module),
            ),
          );
          
          // Reload modules when returning to refresh completion status
          _loadModules();
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Module Number Badge
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: module.isCompleted
                      ? Colors.green[100]
                      : Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: module.isCompleted
                      ? Icon(
                          Icons.check,
                          color: Colors.green[700],
                          size: 20,
                        )
                      : Text(
                          '$moduleNumber',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 16),

              // Module Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      module.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      module.description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Content Type Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            module.contentType == 'link'
                                ? Icons.link
                                : Icons.video_library,
                            size: 14,
                            color: Colors.blue[700],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            module.contentType.toUpperCase(),
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow Icon
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
