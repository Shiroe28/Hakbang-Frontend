import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/assessment_model.dart';

class ModuleAssessmentScreen extends StatefulWidget {
  final String moduleId;
  final String moduleName;
  final String careerId;

  const ModuleAssessmentScreen({
    super.key,
    required this.moduleId,
    required this.moduleName,
    required this.careerId,
  });

  @override
  State<ModuleAssessmentScreen> createState() => _ModuleAssessmentScreenState();
}

class _ModuleAssessmentScreenState extends State<ModuleAssessmentScreen> {
  Assessment? _assessment;
  bool _isLoading = true;
  bool _isSubmitting = false;
  final Map<int, String> _selectedAnswers = {};
  final Map<int, int> _selectedAnswerIndices = {}; // Store indices for comparison
  Map<String, dynamic>? _results;
  
  // Slideshow state
  int _currentQuestionIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadAssessment();
  }

  Future<void> _loadAssessment() async {
    setState(() => _isLoading = true);
    try {
      // Load assessment by module ID since we don't have direct assessment ID
      final assessment = await ApiService.getAssessmentByModuleId(widget.moduleId);
      setState(() {
        _assessment = assessment;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Failed to load assessment: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load assessment: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitAssessment() async {
    // Validate all questions answered
    if (_assessment != null && _selectedAnswers.length != _assessment!.questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please answer all questions before submitting'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Prepare answers as list of selected option indices
      final List<int> answers = [];
      for (int i = 0; i < _assessment!.questions.length; i++) {
        final selectedOption = _selectedAnswers[i];
        final question = _assessment!.questions[i];
        final optionIndex = question.options.indexOf(selectedOption!);
        answers.add(optionIndex);
      }

      print('📤 Submitting answers: $answers');

      final results = await ApiService.submitAssessment(
        assessmentId: _assessment!.id,
        answers: answers,
        careerId: widget.careerId,
      );

      print('✅ Assessment submitted: $results');
      print('🔍 DEBUG - Extracting results:');
      print('   Raw score: ${results['score']}');
      print('   Raw totalQuestions: ${results['totalQuestions']}');
      print('   Raw percentage: ${results['percentage']}');
      print('   Raw passed: ${results['passed']}');
      print('   Raw feedback: ${results['feedback']}');
      print('   Raw results array: ${results['results']}');

      // Check if submission failed
      if (results['success'] == false) {
        setState(() => _isSubmitting = false);
        if (mounted) {
          final errorMessage = results['message'] ?? 'Unknown error';
          print('❌ Submission failed: $errorMessage');
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '❌ Assessment Submission Failed',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(errorMessage),
                  if (errorMessage.contains('careerId')) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Backend Issue: The server is not reading careerId from the request.',
                      style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                    ),
                  ],
                ],
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 8),
              action: SnackBarAction(
                label: 'Dismiss',
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
        }
        return;
      }

      setState(() {
        _results = {
          'score': results['score'] ?? 0,
          'total': results['totalQuestions'] ?? _assessment!.questions.length,
          'percentage': results['percentage'] ?? 0,
          'passed': results['passed'] ?? ((results['percentage'] ?? 0) >= 70),
          'feedback': results['feedback'],
          'detailedResults': results['results'], // Backend's detailed question breakdown
        };
        print('🎯 STORED _results:');
        print('   score: ${_results!['score']}');
        print('   total: ${_results!['total']}');
        print('   percentage: ${_results!['percentage']}');
        _isSubmitting = false;
      });

      // Fetch updated badges after successful assessment
      if ((results['percentage'] ?? 0) >= 70) {
        try {
          print('🎖️ Fetching updated badges after passing assessment...');
          final badgeData = await ApiService.fetchUserBadges();
          
          // Check if new badge was earned
          if (badgeData['newBadgeEarned'] == true && badgeData['badge'] != null) {
            final badge = badgeData['badge'];
            // Show achievement popup
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
                  'earnedFrom': 'assessment',
                },
              );
            }
          }
          
          // Create milestone notification for passing assessment
          if (mounted) {
            await ApiService.createNotification(
              title: '✅ Assessment Passed',
              message: 'Congratulations! You scored ${results['percentage']}% on the assessment',
              type: 'milestone',
            );
            
            // 🌟 Generate AI motivational reflection for quiz passed and show popup
            final motivationalMessage = await ApiService.generateMotivationalReflection(
              milestoneType: 'quiz_passed',
              milestoneName: _assessment!.title,
              additionalContext: {
                'moduleId': widget.moduleId,
                'careerId': widget.careerId,
                'score': results['percentage'],
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
        } catch (e) {
          print('⚠️ Could not fetch badges: $e');
        }
      }
    } catch (e) {
      print('❌ Failed to submit assessment: $e');
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit assessment: ${e.toString()}'),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.amber.shade400, Colors.orange.shade600],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated trophy icon
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
                const SizedBox(height: 16),
                const Text(
                  '🎉 Achievement Unlocked! 🎉',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.orange.shade700,
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
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context); // Close dialog
                          Navigator.pop(context); // Close results
                          Navigator.pop(context); // Close assessment
                          // Navigate to badges screen
                          Navigator.pushNamed(context, '/badges');
                        },
                        icon: const Icon(Icons.emoji_events),
                        label: const Text('View All'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_results == null ? 'Assessment' : 'Results'),
        backgroundColor: const Color(0xFF2c6894),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _results != null
              ? _buildResults()
              : _buildQuestions(),
    );
  }

  Widget _buildQuestions() {
    if (_assessment == null) {
      return const Center(
        child: Text('No assessment data available'),
      );
    }

    final currentQuestion = _assessment!.questions[_currentQuestionIndex];
    final totalQuestions = _assessment!.questions.length;
    final isLastQuestion = _currentQuestionIndex == totalQuestions - 1;

    return Column(
      children: [
        // Progress Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Color(0xFF2c6894),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.moduleName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _assessment!.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Progress Indicator
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: (_currentQuestionIndex + 1) / totalQuestions,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${_currentQuestionIndex + 1}/$totalQuestions',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Current Question Card
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question Number Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2c6894),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Question ${_currentQuestionIndex + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Question Text
                    Text(
                      currentQuestion.questionText,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Options
                    ...currentQuestion.options.asMap().entries.map((entry) {
                      final optionIndex = entry.key;
                      final optionText = entry.value;
                      final isSelected = _selectedAnswers[_currentQuestionIndex] == optionText;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedAnswers[_currentQuestionIndex] = optionText;
                              _selectedAnswerIndices[_currentQuestionIndex] = optionIndex;
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF2c6894).withOpacity(0.1)
                                  : Colors.grey.shade50,
                              border: Border.all(
                                color: isSelected ? const Color(0xFF2c6894) : Colors.grey.shade300,
                                width: isSelected ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected ? const Color(0xFF2c6894) : Colors.grey,
                                      width: 2,
                                    ),
                                    color: isSelected ? const Color(0xFF2c6894) : Colors.transparent,
                                  ),
                                  child: isSelected
                                      ? const Icon(
                                          Icons.check,
                                          size: 18,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    '${String.fromCharCode(65 + optionIndex)}. $optionText',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                      color: isSelected ? const Color(0xFF2c6894) : Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Navigation Buttons
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                // Previous Button
                if (_currentQuestionIndex > 0)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _currentQuestionIndex--;
                        });
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Previous'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                
                if (_currentQuestionIndex > 0) const SizedBox(width: 12),
                
                // Next/Submit Button
                Expanded(
                  flex: _currentQuestionIndex > 0 ? 1 : 2,
                  child: ElevatedButton(
                    onPressed: _isSubmitting
                        ? null
                        : () {
                            if (!_selectedAnswers.containsKey(_currentQuestionIndex)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please select an answer'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                              return;
                            }
                            
                            if (isLastQuestion) {
                              _submitAssessment();
                            } else {
                              setState(() {
                                _currentQuestionIndex++;
                              });
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2c6894),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isLastQuestion ? 'Submit Assessment' : 'Next Question',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (!isLastQuestion) ...[
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward),
                              ],
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResults() {
    print('🎨 Building results display...');
    print('   _results map: $_results');
    
    final score = _results!['score'] ?? 0;
    final total = _results!['total'] ?? _assessment!.questions.length;
    final percentage = _results!['percentage'] ?? ((score / total) * 100).round();
    final passed = _results!['passed'] ?? false;
    
    print('   📊 Display values:');
    print('      score: $score (type: ${score.runtimeType})');
    print('      total: $total (type: ${total.runtimeType})');
    print('      percentage: $percentage (type: ${percentage.runtimeType})');
    print('      passed: $passed');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Score Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: passed
                      ? [const Color(0xFF2c6894), const Color(0xFF1e4a63)]
                      : [Colors.orange.shade400, Colors.orange.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    passed ? Icons.check_circle : Icons.info,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    passed ? 'Congratulations!' : 'Good Effort!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    passed
                        ? 'You passed the assessment!'
                        : 'Keep learning to improve',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '$percentage%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$score out of $total correct',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Question Breakdown
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.list_alt, color: Color(0xFF2c6894)),
                      SizedBox(width: 8),
                      Text(
                        'Question Breakdown',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ..._assessment!.questions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final question = entry.value;
                    
                    // Try to use backend's detailed results first
                    final detailedResults = _results!['detailedResults'] as List?;
                    int userAnswerIndex;
                    int correctAnswerIndex;
                    bool isCorrect;
                    
                    if (detailedResults != null && index < detailedResults.length) {
                      // Use backend data (more reliable)
                      final backendResult = detailedResults[index];
                      userAnswerIndex = backendResult['userAnswer'] ?? -1;
                      correctAnswerIndex = backendResult['correctAnswer'] ?? question.correctOption;
                      isCorrect = backendResult['isCorrect'] ?? false;
                      print('📊 Q${index + 1}: Using BACKEND data - user:$userAnswerIndex, correct:$correctAnswerIndex, isCorrect:$isCorrect');
                    } else {
                      // Fall back to frontend calculation
                      userAnswerIndex = _selectedAnswerIndices[index] ?? -1;
                      correctAnswerIndex = question.correctOption;
                      isCorrect = userAnswerIndex == correctAnswerIndex;
                      print('📊 Q${index + 1}: Using FRONTEND data - user:$userAnswerIndex, correct:$correctAnswerIndex, isCorrect:$isCorrect');
                    }
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isCorrect 
                          ? Colors.green.shade50 
                          : Colors.red.shade50,
                        border: Border.all(
                          color: isCorrect ? Colors.green : Colors.red,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isCorrect ? Icons.check_circle : Icons.cancel,
                                color: isCorrect ? Colors.green : Colors.red,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Question ${index + 1}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isCorrect ? Colors.green.shade900 : Colors.red.shade900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            question.questionText,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // User's Answer
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.person,
                                  size: 18,
                                  color: isCorrect ? Colors.green : Colors.red,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                                      children: [
                                        const TextSpan(
                                          text: 'Your answer: ',
                                          style: TextStyle(fontWeight: FontWeight.w500),
                                        ),
                                        TextSpan(
                                          text: userAnswerIndex >= 0 && userAnswerIndex < question.options.length
                                            ? '${String.fromCharCode(65 + userAnswerIndex)}. ${question.options[userAnswerIndex]}'
                                            : 'Not answered',
                                          style: TextStyle(
                                            color: isCorrect ? Colors.green.shade700 : Colors.red.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!isCorrect) ...[
                            const SizedBox(height: 8),
                            // Correct Answer
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.green.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check,
                                    size: 18,
                                    color: Colors.green.shade700,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                                        children: [
                                          const TextSpan(
                                            text: 'Correct answer: ',
                                            style: TextStyle(fontWeight: FontWeight.w500),
                                          ),
                                          TextSpan(
                                            text: correctAnswerIndex >= 0 && correctAnswerIndex < question.options.length
                                              ? '${String.fromCharCode(65 + correctAnswerIndex)}. ${question.options[correctAnswerIndex]}'
                                              : 'N/A',
                                            style: TextStyle(
                                              color: Colors.green.shade700,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Feedback
          if (_results!['feedback'] != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.feedback, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Feedback',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _results!['feedback'],
                      style: const TextStyle(fontSize: 15, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Actions
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context, passed);
              },
              icon: const Icon(Icons.check),
              label: const Text('Continue'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2c6894),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          if (!passed) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _results = null;
                    _selectedAnswers.clear();
                    _selectedAnswerIndices.clear();
                    _currentQuestionIndex = 0;
                  });
                  _loadAssessment();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retake Assessment'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
