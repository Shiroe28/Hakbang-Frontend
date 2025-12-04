import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../models/career_model.dart';
import 'recommendation_results_screen.dart';

class RecommendationQuizScreen extends StatefulWidget {
  const RecommendationQuizScreen({super.key});

  @override
  State<RecommendationQuizScreen> createState() =>
      _RecommendationQuizScreenState();
}

class _RecommendationQuizScreenState extends State<RecommendationQuizScreen> {
  int _currentQuestionIndex = 0;
  final Map<int, int> _answers = {};
  bool _isSubmitting = false;

  // 10 Real-Life Scenario Questions for Career Matching
  final List<QuizQuestion> _questions = [
    // Question 1: Work Style Preference
    QuizQuestion(
      question: 'When working on a group project, you usually...',
      options: [
        'Take charge and organize the team',
        'Focus on your specific task independently',
        'Help others and ensure everyone is aligned',
        'Come up with creative ideas and solutions',
      ],
    ),
    // Question 2: Problem-Solving Approach
    QuizQuestion(
      question: 'When you encounter a difficult puzzle or problem, you...',
      options: [
        'Break it down into smaller, logical steps',
        'Look for patterns and connections',
        'Research how others have solved similar problems',
        'Try different approaches until something works',
      ],
    ),
    // Question 3: Daily Habit - Learning
    QuizQuestion(
      question: 'In your free time, you prefer to...',
      options: [
        'Watch tutorials or learn new skills online',
        'Play strategy games or solve puzzles',
        'Create art, music, or design things',
        'Read about technology trends and news',
      ],
    ),
    // Question 4: Communication Style
    QuizQuestion(
      question: 'When explaining something technical to a friend, you...',
      options: [
        'Use simple analogies and visual examples',
        'Give detailed step-by-step instructions',
        'Show them by doing it yourself first',
        'Share resources and let them figure it out',
      ],
    ),
    // Question 5: Attention to Detail
    QuizQuestion(
      question: 'When you notice a small error in an app or website, you...',
      options: [
        'Feel bothered and want to fix it immediately',
        'Think about how it could have been prevented',
        'Wonder what caused the bug technically',
        'Notice it but move on quickly',
      ],
    ),
    // Question 6: Work Environment
    QuizQuestion(
      question: 'Your ideal workspace looks like...',
      options: [
        'A quiet corner with minimal distractions',
        'A collaborative open space with teammates',
        'A coffee shop or flexible location',
        'A creative studio with visual inspiration',
      ],
    ),
    // Question 7: Decision Making
    QuizQuestion(
      question: 'When making an important decision, you rely on...',
      options: [
        'Data, facts, and logical analysis',
        'Intuition and past experiences',
        'Input from people you trust',
        'Weighing all pros and cons carefully',
      ],
    ),
    // Question 8: Task Preference
    QuizQuestion(
      question: 'Which daily task sounds most enjoyable to you?',
      options: [
        'Organizing and optimizing a messy system',
        'Building something new from scratch',
        'Analyzing data to find insights',
        'Designing a beautiful and user-friendly interface',
      ],
    ),
    // Question 9: Challenge Response
    QuizQuestion(
      question: 'When faced with a completely new challenge, you...',
      options: [
        'Dive in and learn as you go',
        'Research thoroughly before starting',
        'Find someone experienced to guide you',
        'Break it into smaller, manageable parts',
      ],
    ),
    // Question 10: Long-term Motivation
    QuizQuestion(
      question: 'What motivates you most in your work?',
      options: [
        'Creating things that people actually use',
        'Solving complex problems others cannot',
        'Making things look beautiful and intuitive',
        'Seeing measurable results from your efforts',
      ],
    ),
  ];

  void _selectAnswer(int answerIndex) {
    setState(() {
      _answers[_currentQuestionIndex] = answerIndex;
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _submitQuiz();
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  Future<void> _submitQuiz() async {
    if (_answers.length != _questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please answer all questions'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Convert answers to the format expected by the API
      final List<Map<String, dynamic>> quizResponses = [];
      for (var i = 0; i < _questions.length; i++) {
        quizResponses.add({
          'question': _questions[i].question,
          'answer': _questions[i].options[_answers[i]!],
          'answerIndex': _answers[i],
        });
      }

      final List<Career> recommendations =
          await ApiService.getAIRecommendations(quizResponses: quizResponses);

      if (!mounted) return;

      // Navigate to results screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              RecommendationResultsScreen(recommendations: recommendations),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to get recommendations: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[_currentQuestionIndex];
    final selectedAnswer = _answers[_currentQuestionIndex];

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
                    'Career Quiz',
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

          // Progress Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Progress bar (better for 10 questions)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: (_currentQuestionIndex + 1) / _questions.length,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2c6894)),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${((_currentQuestionIndex + 1) / _questions.length * 100).toInt()}% Complete',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: const Color(0xFF2c6894),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question Text
                  Text(
                    currentQuestion.question,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Answer Options
                  ...List.generate(
                    currentQuestion.options.length,
                    (index) => _buildAnswerOption(
                      currentQuestion.options[index],
                      index,
                      selectedAnswer == index,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Navigation Buttons
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                // Previous Button
                if (_currentQuestionIndex > 0)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isSubmitting ? null : _previousQuestion,
                      icon: const Icon(Icons.arrow_back),
                      label: Text(
                        'Previous',
                        style: GoogleFonts.poppins(),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: Color(0xFF2c6894)),
                        foregroundColor: const Color(0xFF2c6894),
                      ),
                    ),
                  ),
                if (_currentQuestionIndex > 0) const SizedBox(width: 16),

                // Next/Submit Button
                Expanded(
                  flex: _currentQuestionIndex == 0 ? 1 : 1,
                  child: ElevatedButton.icon(
                    onPressed: (_isSubmitting || selectedAnswer == null)
                        ? null
                        : _nextQuestion,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Icon(
                            _currentQuestionIndex == _questions.length - 1
                                ? Icons.check
                                : Icons.arrow_forward,
                          ),
                    label: Text(
                      _currentQuestionIndex == _questions.length - 1
                          ? 'Get Recommendations'
                          : 'Next',
                      style: GoogleFonts.poppins(
                        fontSize: _currentQuestionIndex == _questions.length - 1 ? 13 : 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerOption(String option, int index, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () => _selectAnswer(index),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF2c6894).withOpacity(0.1)
                : Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? const Color(0xFF2c6894) : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Radio Circle
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF2c6894)
                        : Colors.grey[400]!,
                    width: 2,
                  ),
                  color:
                      isSelected ? const Color(0xFF2c6894) : Colors.transparent,
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.white,
                      )
                    : null,
              ),
              const SizedBox(width: 16),

              // Option Text
              Expanded(
                child: Text(
                  option,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                    color:
                        isSelected ? const Color(0xFF2c6894) : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuizQuestion {
  final String question;
  final List<String> options;

  QuizQuestion({
    required this.question,
    required this.options,
  });
}
