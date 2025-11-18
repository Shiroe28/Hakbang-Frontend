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

  final List<QuizQuestion> _questions = [
    QuizQuestion(
      question: 'What interests you most?',
      options: [
        'Building and creating things',
        'Solving complex problems',
        'Working with data and analytics',
        'Designing visual experiences',
      ],
    ),
    QuizQuestion(
      question: 'What kind of projects excite you?',
      options: [
        'Mobile apps and user interfaces',
        'Backend systems and APIs',
        'Machine learning and AI',
        'Web design and frontend',
      ],
    ),
    QuizQuestion(
      question: 'How do you prefer to work?',
      options: [
        'Independently on focused tasks',
        'Collaborating with a team',
        'Leading and managing projects',
        'Researching and experimenting',
      ],
    ),
    QuizQuestion(
      question: 'What technical skills do you want to develop?',
      options: [
        'Programming and coding',
        'Database management',
        'Cloud infrastructure',
        'UI/UX design',
      ],
    ),
    QuizQuestion(
      question: 'What type of work environment appeals to you?',
      options: [
        'Fast-paced startup',
        'Established tech company',
        'Remote/flexible work',
        'Creative agency',
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
                // Progress dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _questions.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: index <= _currentQuestionIndex ? 32 : 24,
                      height: 8,
                      decoration: BoxDecoration(
                        color: index < _currentQuestionIndex
                            ? const Color(0xFF2c6894)
                            : index == _currentQuestionIndex
                                ? const Color(0xFF2c6894)
                                : Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
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
                        fontSize: 15,
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
