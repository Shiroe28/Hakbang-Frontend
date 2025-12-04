import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';

class ResumeBuilderScreen extends StatefulWidget {
  const ResumeBuilderScreen({super.key});

  @override
  State<ResumeBuilderScreen> createState() => _ResumeBuilderScreenState();
}

class _ResumeBuilderScreenState extends State<ResumeBuilderScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for resume fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _summaryController = TextEditingController();
  final TextEditingController _educationController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  final TextEditingController _projectsController = TextEditingController();

  bool _isLoading = false;
  bool _showFeedback = false;
  Map<String, dynamic>? _feedback;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _summaryController.dispose();
    _educationController.dispose();
    _experienceController.dispose();
    _skillsController.dispose();
    _projectsController.dispose();
    super.dispose();
  }

  Future<void> _getAIFeedback() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _showFeedback = false;
      _feedback = null;
    });

    try {
      // Build resume text
      final resumeText = '''
Name: ${_nameController.text}
Email: ${_emailController.text}
Phone: ${_phoneController.text}

PROFESSIONAL SUMMARY
${_summaryController.text}

EDUCATION
${_educationController.text}

EXPERIENCE
${_experienceController.text}

SKILLS
${_skillsController.text}

PROJECTS
${_projectsController.text}
''';

      print('📤 Sending resume for feedback...');
      final result =
          await ApiService.getAIResumeFeedback(resumeText: resumeText);
      print('📥 Received result: $result');

      // Backend returns: { rating: 0, strengths: [], improvements: [], suggestions: [] }
      // Convert to format our UI expects
      Map<String, dynamic> feedbackData;

      if (result.containsKey('rating')) {
        // Backend format: { rating, strengths, improvements, suggestions }
        final strengths = (result['strengths'] as List?)?.cast<String>() ?? [];
        final improvements =
            (result['improvements'] as List?)?.cast<String>() ?? [];
        final suggestions =
            (result['suggestions'] as List?)?.cast<String>() ?? [];

        // Build feedback text
        String feedbackText = '';

        if (strengths.isNotEmpty) {
          feedbackText += '✅ **Strengths:**\n';
          for (var strength in strengths) {
            feedbackText += '• $strength\n';
          }
          feedbackText += '\n';
        }

        if (improvements.isNotEmpty) {
          feedbackText += '📈 **Areas to Improve:**\n';
          for (var improvement in improvements) {
            feedbackText += '• $improvement\n';
          }
          feedbackText += '\n';
        }

        if (suggestions.isNotEmpty) {
          feedbackText += '💡 **Suggestions:**\n';
          for (var suggestion in suggestions) {
            feedbackText += '• $suggestion\n';
          }
        }

        if (feedbackText.isEmpty) {
          feedbackText =
              'No specific feedback available. Please ensure all required fields are filled with meaningful content.';
        }

        feedbackData = {
          'feedback': feedbackText,
          'score': result['rating'] ?? 0,
        };
      } else if (result.containsKey('feedback')) {
        // Old format: { feedback: "...", score: 8 }
        feedbackData = {
          'feedback': result['feedback'],
          'score': result['score'],
        };
      } else {
        // Unknown format
        feedbackData = {
          'feedback': 'Received unexpected response format from backend.',
          'score': 0,
        };
      }

      print('✅ Parsed feedback data: $feedbackData');

      setState(() {
        _feedback = feedbackData;
        _showFeedback = true;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ AI feedback received!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('❌ Resume feedback error: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get feedback:\n${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _getAIFeedback,
            ),
          ),
        );
      }
    }
  }

  void _clearForm() {
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _summaryController.clear();
    _educationController.clear();
    _experienceController.clear();
    _skillsController.clear();
    _projectsController.clear();
    setState(() {
      _showFeedback = false;
      _feedback = null;
    });
  }

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
              color: Color(0xFF2c6894),
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
                    'AI Feedback Resume',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.help_outline, color: Colors.white),
                  onPressed: () {
                    _showHelpDialog();
                  },
                ),
              ],
            ),
          ),

          // Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2c6894).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF2c6894).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              'assets/images/openai-logo.jpg',
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'AI-Powered Resume Feedback',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Fill in your resume details and get instant AI feedback!',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Personal Information Section
                    _buildSectionHeader('Personal Information', Icons.person),
                    const SizedBox(height: 12),

                    _buildTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      hint: 'Juan Dela Cruz',
                      icon: Icons.badge,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'juan.delacruz@email.com',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    _buildTextField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      hint: '+63 912 345 6789',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                    ),

                    const SizedBox(height: 24),

                    // Professional Summary Section
                    _buildSectionHeader(
                        'Professional Summary', Icons.description),
                    const SizedBox(height: 12),

                    _buildTextField(
                      controller: _summaryController,
                      label: 'Summary',
                      hint:
                          'A brief summary of your professional background and career goals...',
                      icon: Icons.article,
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a professional summary';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // Education Section
                    _buildSectionHeader('Education', Icons.school),
                    const SizedBox(height: 12),

                    _buildTextField(
                      controller: _educationController,
                      label: 'Education',
                      hint:
                          'Bachelor of Science in Computer Science\nUniversity of the Philippines\n2020-2024',
                      icon: Icons.school,
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your education background';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // Experience Section
                    _buildSectionHeader('Work Experience', Icons.work),
                    const SizedBox(height: 12),

                    _buildTextField(
                      controller: _experienceController,
                      label: 'Experience',
                      hint:
                          'Software Developer Intern\nTech Company Inc.\nJune 2023 - August 2023\n- Developed web applications\n- Collaborated with team',
                      icon: Icons.work_outline,
                      maxLines: 6,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your work experience (or write "Fresh Graduate")';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // Skills Section
                    _buildSectionHeader('Skills', Icons.stars),
                    const SizedBox(height: 12),

                    _buildTextField(
                      controller: _skillsController,
                      label: 'Skills',
                      hint:
                          'JavaScript, React, Node.js, Python, Git, SQL, Communication, Problem-solving',
                      icon: Icons.code,
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your skills';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // Projects Section
                    _buildSectionHeader('Projects', Icons.folder),
                    const SizedBox(height: 12),

                    _buildTextField(
                      controller: _projectsController,
                      label: 'Projects',
                      hint:
                          'E-commerce Website\n- Built using React and Node.js\n- Implemented payment integration\n- https://github.com/user/project',
                      icon: Icons.folder_open,
                      maxLines: 5,
                    ),

                    const SizedBox(height: 32),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isLoading ? null : _clearForm,
                            icon: const Icon(Icons.clear),
                            label: const Text('Clear Form'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(color: Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _getAIFeedback,
                            icon: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : const Icon(Icons.psychology),
                            label: Text(_isLoading
                                ? 'Analyzing...'
                                : 'Get AI Feedback'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Feedback Section
                    if (_showFeedback && _feedback != null) ...[
                      const SizedBox(height: 32),
                      _buildFeedbackSection(),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF2c6894)),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildFeedbackSection() {
    final feedback = _feedback!['feedback'] ?? '';
    final score = _feedback!['score'];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade50, Colors.white],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'AI Feedback',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Powered by AI Assistant',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (score != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _getScoreColor(score),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$score/10',
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

              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 16),

              // Feedback Content
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  feedback,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: Colors.black87,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _showFeedback = false;
                        });
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Resume'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _getAIFeedback,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Re-analyze'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 8) return Colors.green;
    if (score >= 6) return Colors.orange;
    return Colors.red;
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: Colors.blue),
            SizedBox(width: 8),
            Text('AI Feedback Resume Tips'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTipItem(
                '📝 Be Specific',
                'Use concrete examples and quantify your achievements when possible.',
              ),
              _buildTipItem(
                '🎯 Tailor Your Resume',
                'Customize your resume for each IT career path you\'re targeting.',
              ),
              _buildTipItem(
                '💡 Highlight Skills',
                'List both technical skills (programming languages) and soft skills (communication).',
              ),
              _buildTipItem(
                '🚀 Include Projects',
                'Personal and academic projects show practical experience.',
              ),
              _buildTipItem(
                '✨ Keep it Clean',
                'Use clear formatting and avoid typos. Keep it to 1-2 pages.',
              ),
              _buildTipItem(
                '🤖 Use AI Feedback',
                'Get multiple rounds of feedback as you improve your resume.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
