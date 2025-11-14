import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import '../models/career_model.dart';
import '../models/module_model.dart';
import '../models/assessment_model.dart';
import '../config/network_config.dart';
import 'storage_service.dart';

class ApiService {
  // Platform-specific base URL configuration
  static String get baseUrl => NetworkConfig.baseUrl;

  // Helper method to get headers with authentication
  static Future<Map<String, String>> _getHeaders({bool needsAuth = false}) async {
    final headers = {
      'Content-Type': 'application/json',
    };

    if (needsAuth) {
      final token = await StorageService.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // Authentication APIs

  /// Register a new user
  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'name': username,  // Backend expects 'name' field
          'email': email,
          'password': password,
          'role': role,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Registration failed'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Login user
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'token': data['token'],
          'role': data['role'],
          'user': data['user'], // if backend returns user data
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Login failed'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Request password reset code
  static Future<void> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password'),
        headers: await _getHeaders(),
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Success - code sent
        return;
      } else {
        throw Exception(data['error'] ?? 'Failed to send reset code');
      }
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Network error. Please check your connection.');
    }
  }

  /// Reset password with code
  static Future<void> resetPassword(
    String email,
    String code,
    String newPassword,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/reset-password'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'email': email,
          'code': code,
          'newPassword': newPassword,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Success - password reset
        return;
      } else {
        throw Exception(data['error'] ?? 'Failed to reset password');
      }
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Network error. Please check your connection.');
    }
  }

  // Public Content APIs (No authentication needed)

  /// Get all careers
  static Future<List<Career>> getCareers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/careers'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Career.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load careers');
      }
    } catch (e) {
      throw Exception('Error fetching careers: $e');
    }
  }

  /// Get all modules, optionally filtered by careerId
  static Future<List<Module>> getModules({String? careerId}) async {
    try {
      String url = '$baseUrl/learning/modules';
      if (careerId != null && careerId.isNotEmpty) {
        url += '?careerId=$careerId';
        print('📤 Getting modules for career ID: "$careerId"');
        print('📤 Full URL: $url');
      } else {
        print('📤 Getting all modules (no career filter)');
        print('⚠️ careerId is ${careerId == null ? "null" : "empty"}');
      }

      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      print('📥 Modules response: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Parse response as object first
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        
        // Extract the modules list from the 'data' property
        final List<dynamic> data = responseData['data'] ?? [];
        print('✅ Found ${data.length} modules${careerId != null && careerId.isNotEmpty ? " for career: $careerId" : " (all careers)"}');
        
        // Log first module's careerId to verify filtering
        if (data.isNotEmpty && careerId != null && careerId.isNotEmpty) {
          final firstModule = data[0];
          print('📌 First module careerId: ${firstModule['careerId']}');
          print('📌 Requested careerId: $careerId');
          print('📌 Match: ${firstModule['careerId'] == careerId}');
        }
        
        return data.map((json) => Module.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load modules');
      }
    } catch (e) {
      print('❌ Error fetching modules: $e');
      throw Exception('Error fetching modules: $e');
    }
  }

  /// Get a single module by ID
  static Future<Module> getModuleById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/learning/modules/$id'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Module.fromJson(data);
      } else {
        throw Exception('Failed to load module');
      }
    } catch (e) {
      throw Exception('Error fetching module: $e');
    }
  }

  /// Get assessment for a specific module
  static Future<Assessment> getAssessmentByModuleId(String moduleId) async {
    try {
      print('📤 Getting assessment for module: $moduleId');
      
      final response = await http.get(
        Uri.parse('$baseUrl/learning/assessments/module/$moduleId'),
        headers: await _getHeaders(),
      );

      print('📥 Assessment response status: ${response.statusCode}');
      print('📦 Assessment response body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        
        // Backend returns: { success: true, data: {...assessment...} }
        if (decoded is Map && decoded.containsKey('data')) {
          print('✅ Assessment data found');
          return Assessment.fromJson(Map<String, dynamic>.from(decoded['data']));
        } else if (decoded is Map && decoded.containsKey('_id')) {
          // Direct assessment object
          return Assessment.fromJson(Map<String, dynamic>.from(decoded));
        } else {
          throw Exception('Unexpected response format');
        }
      } else if (response.statusCode == 404) {
        throw Exception('No assessment found for this module');
      } else {
        throw Exception('Failed to load assessment: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching assessment: $e');
      throw Exception('Error fetching assessment: $e');
    }
  }

  // Protected User APIs (Requires authentication)

  /// Mark a module as complete
  static Future<bool> markModuleComplete(String moduleId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/learning/modules/$moduleId/progress'),
        headers: await _getHeaders(needsAuth: true),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error marking module as complete: $e');
    }
  }

  /// Submit quiz answers
  static Future<Map<String, dynamic>> submitAssessment({
    required String assessmentId,
    required List<int> answers,
    required String careerId,
  }) async {
    try {
      print('📤 Submitting assessment: $assessmentId');
      print('   Answers: $answers');
      print('   Career ID: $careerId');
      
      final response = await http.post(
        Uri.parse('$baseUrl/learning/assessments/$assessmentId/submit'),
        headers: await _getHeaders(needsAuth: true),
        body: jsonEncode({
          'answers': answers,
          'careerId': careerId,
        }),
      );

      print('📥 Submit response status: ${response.statusCode}');
      print('📦 Submit response body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        
        // Backend returns: { success: true, data: { score, total, percentage, passed } }
        if (decoded is Map && decoded.containsKey('data')) {
          final data = decoded['data'];
          return {
            'success': true,
            'score': data['score'] ?? 0,
            'totalQuestions': data['total'] ?? answers.length,
            'percentage': data['percentage'] ?? 0.0,
            'passed': data['passed'] ?? false,
          };
        } else if (decoded is Map && decoded.containsKey('score')) {
          // Direct response format
          return {
            'success': true,
            'score': decoded['score'] ?? 0,
            'totalQuestions': decoded['total'] ?? answers.length,
            'percentage': decoded['percentage'] ?? 0.0,
            'passed': decoded['passed'] ?? false,
          };
        } else {
          return {'success': false, 'message': 'Unexpected response format'};
        }
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['error'] ?? 'Failed to submit assessment'};
      }
    } catch (e) {
      print('❌ Submit assessment error: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Submit AI quiz for career recommendations (QUIZ-BASED - NEW BACKEND ENDPOINT!)
  static Future<List<Map<String, dynamic>>> getAIQuizRecommendations({
    required List<Map<String, dynamic>> quizResponses,
  }) async {
    try {
      print('📤 Sending quiz-based AI recommendations request...');
      print('Quiz responses: $quizResponses');
      
      final response = await http.post(
        Uri.parse('$baseUrl/ai/quiz-recommendations'),  // NEW ENDPOINT!
        headers: await _getHeaders(needsAuth: true),
        body: jsonEncode({
          'quizResponses': quizResponses,
        }),
      );

      print('📥 Quiz recommendations response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        
        // Backend returns: { success: true, data: [...career objects with matchPercentage and reasons...] }
        if (decoded is Map && decoded.containsKey('data')) {
          final List<dynamic> careerList = decoded['data'];
          print('✅ Parsed ${careerList.length} quiz-based recommendations');
          
          // Return as list of maps (includes matchPercentage and reasons)
          return careerList.map((item) => Map<String, dynamic>.from(item)).toList();
        } else {
          throw Exception('Unexpected response format: ${decoded.runtimeType}');
        }
      } else {
        throw Exception('Failed to get quiz recommendations: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Quiz recommendations error: $e');
      throw Exception('Error getting quiz recommendations: $e');
    }
  }

  /// Profile-based career recommendations (HANDLES BACKEND FORMAT)
  static Future<List<Career>> getAIRecommendations({
    required List<Map<String, dynamic>> quizResponses,
  }) async {
    try {
      print('📤 Sending profile-based AI recommendations request...');
      print('Quiz responses: $quizResponses');
      
      final response = await http.post(
        Uri.parse('$baseUrl/ai/recommendations'),
        headers: await _getHeaders(needsAuth: true),
        body: jsonEncode({
          'quizResponses': quizResponses,
        }),
      );

      print('📥 AI recommendations response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        
        // Backend returns: { success: true, data: { careers: [...] } }
        // OR: { success: true, data: [...] }
        // OR: direct array [...]
        List<dynamic> careerList;
        
        if (decoded is Map) {
          if (decoded.containsKey('data')) {
            final data = decoded['data'];
            // Check if data has 'careers' property
            if (data is Map && data.containsKey('careers')) {
              careerList = data['careers'];
            } else if (data is List) {
              careerList = data;
            } else {
              throw Exception('Unexpected data format: ${data.runtimeType}');
            }
          } else if (decoded.containsKey('careers')) {
            careerList = decoded['careers'];
          } else {
            throw Exception('No data or careers found in response');
          }
        } else if (decoded is List) {
          careerList = decoded;
        } else {
          throw Exception('Unexpected response format: ${decoded.runtimeType}');
        }
        
        print('✅ Found ${careerList.length} career recommendations');
        
        // Convert backend format to Career objects
        // Backend returns: { careerTitle, confidenceScore, reason }
        // We need to match these to actual careers from database to get IDs
        final List<Career> careers = [];
        
        // Fetch all careers from database to match against AI recommendations
        try {
          final allCareers = await getCareers();
          print('📚 Fetched ${allCareers.length} careers from database for matching');
          
          for (var item in careerList) {
            final aiCareerTitle = (item['careerTitle'] ?? item['title'] ?? '').toString().toLowerCase().trim();
            
            // Try to find matching career in database
            Career? matchedCareer;
            int bestMatchScore = 0;
            
            for (var dbCareer in allCareers) {
              final dbTitle = dbCareer.title.toLowerCase().trim();
              int matchScore = 0;
              
              // Exact match (highest priority)
              if (dbTitle == aiCareerTitle) {
                matchScore = 100;
              }
              // Contains match
              else if (dbTitle.contains(aiCareerTitle) || aiCareerTitle.contains(dbTitle)) {
                matchScore = 80;
              }
              // Word-by-word match (e.g., "Software Developer" matches "Software Engineer")
              else {
                final aiWords = aiCareerTitle.split(' ');
                final dbWords = dbTitle.split(' ');
                int wordMatches = 0;
                for (var aiWord in aiWords) {
                  if (aiWord.length < 3) continue; // Skip short words like "a", "in"
                  for (var dbWord in dbWords) {
                    if (dbWord.contains(aiWord) || aiWord.contains(dbWord)) {
                      wordMatches++;
                      break;
                    }
                  }
                }
                if (wordMatches > 0) {
                  matchScore = (wordMatches * 60 ~/ aiWords.length); // Percentage-based score
                }
              }
              
              // Keep best match
              if (matchScore > bestMatchScore) {
                bestMatchScore = matchScore;
                matchedCareer = dbCareer;
              }
            }
            
            if (matchedCareer != null && bestMatchScore >= 60) {
              // Use database career with real ID
              print('✅ Matched "$aiCareerTitle" to database career: ${matchedCareer.title} (ID: ${matchedCareer.id}, score: $bestMatchScore)');
              careers.add(matchedCareer);
            } else {
              // Fallback: create career without ID (will show all modules)
              print('⚠️ No database match found for: $aiCareerTitle (best score: $bestMatchScore)');
              careers.add(Career(
                id: '', // No ID - will show all modules
                title: item['careerTitle'] ?? item['title'] ?? 'Unknown Career',
                description: item['reason'] ?? item['description'] ?? '',
                salaryRange: item['salaryRange'] ?? 'Salary varies',
              ));
            }
          }
        } catch (e) {
          print('⚠️ Failed to fetch careers for matching: $e');
          // Fallback: create careers without IDs
          for (var item in careerList) {
            careers.add(Career(
              id: '',
              title: item['careerTitle'] ?? item['title'] ?? 'Unknown Career',
              description: item['reason'] ?? item['description'] ?? '',
              salaryRange: item['salaryRange'] ?? 'Salary varies',
            ));
          }
        }
        
        print('✅ Converted to ${careers.length} Career objects with IDs');
        return careers;
      } else {
        throw Exception('Failed to get AI recommendations: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ AI recommendations error: $e');
      throw Exception('Error getting AI recommendations: $e');
    }
  }

  /// Get current logged-in user
  static Future<Map<String, dynamic>?> getMe() async {
    try {
      print('📤 Fetching current user from /api/users/me...');
      
      // Try /api/users/me first (as documented in ALL_BACKEND_ISSUES.md)
      final response = await http.get(
        Uri.parse('$baseUrl/users/me'),
        headers: await _getHeaders(needsAuth: true),
      );

      print('📥 GET /api/users/me response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('📦 Response body: $data');
        
        // backend returns { success: true, data: user }
        if (data is Map && data.containsKey('data')) {
          print('✅ User data found in response');
          return Map<String, dynamic>.from(data['data']);
        } else {
          print('⚠️ Unexpected response format, returning raw data');
          return Map<String, dynamic>.from(data);
        }
      } else {
        print('❌ Failed to get user: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error in getMe(): $e');
      return null;
    }
  }

  /// Update user profile
  static Future<Map<String, dynamic>> updateProfile({
    required String username,
    required String email,
  }) async {
    try {
      print('📤 Sending PUT request to /api/users/profile...');
      print('   Request body: {"username": "$username", "email": "$email"}');
      
      final response = await http.put(
        Uri.parse('$baseUrl/users/profile'),
        headers: await _getHeaders(needsAuth: true),
        body: jsonEncode({
          'username': username,
          'email': email,
        }),
      );

      print('📥 PUT /api/users/profile response: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Profile update successful!');
        return data;
      } else {
        print('❌ Profile update failed with status ${response.statusCode}');
        print('   Error body: ${response.body}');
        throw Exception('Failed to update profile: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Profile update exception: $e');
      throw Exception('Error updating profile: $e');
    }
  }

  /// Get all community posts
  static Future<List<Map<String, dynamic>>> getCommunityPosts() async {
    try {
      print('📤 Fetching community posts...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/community/posts'),
        headers: await _getHeaders(),
      );

      print('📥 Community posts response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        print('📦 Raw response: $decoded');
        
        // Backend returns: { success: true, data: [...posts...], pagination: {...} }
        if (decoded is Map && decoded.containsKey('data')) {
          final List<dynamic> posts = decoded['data'];
          print('✅ Found ${posts.length} community posts');
          
          // Normalize posts with authorName, authorRole, profilePicture
          return posts.map<Map<String, dynamic>>((p) {
            // Extract authorId - handle both String and Map formats
            String authorIdStr;
            if (p['authorId'] is String) {
              authorIdStr = p['authorId'];
            } else if (p['authorId'] is Map) {
              authorIdStr = p['authorId']['_id'] ?? '';
            } else {
              authorIdStr = '';
            }
            
            return {
              '_id': p['_id'] ?? '',
              'title': p['title'] ?? '',
              'content': p['content'] ?? '',
              'authorId': authorIdStr,
              'authorName': p['authorName'] ?? (p['authorId'] is Map ? (p['authorId']['name'] ?? 'Unknown') : 'Unknown'),
              'authorRole': p['authorRole'] ?? (p['authorId'] is Map ? (p['authorId']['role'] ?? 'student') : 'student'),
              'profilePicture': p['authorPicture'] ?? p['profilePicture'] ?? (p['authorId'] is Map ? p['authorId']['profilePicture'] : null),
              'category': p['category'] ?? 'general',
              'createdAt': p['createdAt'] ?? '',
              'likes': p['likes'] ?? 0,
              'commentCount': p['commentCount'] ?? (p['comments']?.length ?? 0),
            };
          }).toList();
        } else if (decoded is List) {
          // Direct array format (fallback)
          print('✅ Found ${decoded.length} community posts (direct array)');
          return decoded.map<Map<String, dynamic>>((p) {
            return {
              '_id': p['_id'],
              'title': p['title'],
              'content': p['content'],
              'authorId': p['authorId'],
              'authorName': p['authorName'] ?? 'Unknown',
              'authorRole': p['authorRole'] ?? 'student',
              'profilePicture': p['profilePicture'],
              'category': p['category'] ?? 'general',
              'createdAt': p['createdAt'],
              'likes': p['likes'] ?? 0,
              'commentCount': p['commentCount'] ?? 0,
            };
          }).toList();
        } else {
          print('⚠️ Unexpected response format');
          throw Exception('Unexpected response format');
        }
      } else {
        print('❌ Failed to load posts: ${response.statusCode}');
        throw Exception('Failed to load posts: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching posts: $e');
      rethrow;
    }
  }

  /// Create a new community post
  static Future<Map<String, dynamic>> createCommunityPost({
    required String title,
    required String content,
    String category = 'general',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/community/posts'),
        headers: await _getHeaders(needsAuth: true),
        body: jsonEncode({
          'title': title,
          'content': content,
          'category': category,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create post: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating post: $e');
    }
  }

  /// Send message to AI chatbot with OpenAI integration
  static Future<String> sendAIChatMessage({
    required String message,
    List<Map<String, String>>? conversationHistory,
  }) async {
    try {
      print('📤 Sending AI chat message: $message');
      
      final response = await http.post(
        Uri.parse('$baseUrl/ai/chat'),
        headers: await _getHeaders(needsAuth: true),
        body: jsonEncode({
          'message': message,
          'conversationHistory': conversationHistory ?? [],
        }),
      );

      print('📥 AI chat response status: ${response.statusCode}');
      print('📥 AI chat response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Handle different response formats
        if (data is Map) {
          // Format 1: { reply: "text" }
          if (data.containsKey('reply')) {
            final reply = data['reply'];
            // Clean up reply - remove {response:, timestamp:} if present
            if (reply is String) {
              return reply.replaceAll(RegExp(r'\{response:\s*'), '')
                          .replaceAll(RegExp(r',?\s*timestamp:\s*[^}]*\}'), '')
                          .trim();
            }
            return reply.toString();
          }
          // Format 2: { data: { reply: "text" } }
          else if (data.containsKey('data') && data['data'] is Map) {
            final reply = data['data']['reply'] ?? data['data'].toString();
            if (reply is String) {
              return reply.replaceAll(RegExp(r'\{response:\s*'), '')
                          .replaceAll(RegExp(r',?\s*timestamp:\s*[^}]*\}'), '')
                          .trim();
            }
            return reply.toString();
          }
          // Format 3: { success: true, reply: "text", timestamp: "..." }
          else if (data.containsKey('success') && data.containsKey('reply')) {
            return data['reply'].toString();
          }
        }
        
        throw Exception('Invalid response format from AI');
      } else {
        throw Exception('Failed to get AI response: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ AI chat error: $e');
      throw Exception('Error sending message to AI: $e');
    }
  }

  /// Get AI Resume Feedback (NEW!)
  static Future<Map<String, dynamic>> getAIResumeFeedback({
    required String resumeText,
  }) async {
    try {
      print('📤 Sending resume for AI feedback...');
      
      final response = await http.post(
        Uri.parse('$baseUrl/ai/resume-feedback'),
        headers: await _getHeaders(needsAuth: true),
        body: jsonEncode({
          'resumeText': resumeText,
        }),
      );

      print('📥 Resume feedback response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        
        // Backend returns: { success: true, data: { feedback: {...} } }
        if (decoded is Map && decoded.containsKey('data')) {
          return Map<String, dynamic>.from(decoded['data']);
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to get resume feedback: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Resume feedback error: $e');
      throw Exception('Error getting resume feedback: $e');
    }
  }

  /// Get AI Skill Gap Analysis (NEW!)
  static Future<Map<String, dynamic>> getAISkillGapAnalysis({
    required List<String> currentSkills,
    required String targetCareer,
  }) async {
    try {
      print('📤 Sending skill gap analysis request...');
      print('Current skills: $currentSkills');
      print('Target career: $targetCareer');
      
      final response = await http.post(
        Uri.parse('$baseUrl/ai/skill-gap'),
        headers: await _getHeaders(needsAuth: true),
        body: jsonEncode({
          'currentSkills': currentSkills,
          'targetCareer': targetCareer,
        }),
      );

      print('📥 Skill gap analysis response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        
        // Backend returns: { success: true, data: { missingSkills: [...], learningPath: [...], recommendations: [...] } }
        if (decoded is Map && decoded.containsKey('data')) {
          return Map<String, dynamic>.from(decoded['data']);
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to get skill gap analysis: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Skill gap analysis error: $e');
      throw Exception('Error getting skill gap analysis: $e');
    }
  }

  /// Upload profile picture (multipart form data)
  /// Upload profile picture from XFile (cross-platform)
  static Future<String> uploadProfilePictureFromXFile(XFile imageFile) async {
    try {
      print('📤 Uploading profile picture...');
      
      final token = await StorageService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final uri = Uri.parse('$baseUrl/users/profile/picture');
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token';

      // Read file as bytes (works on all platforms including web)
      final bytes = await imageFile.readAsBytes();
      final filename = imageFile.name;
      
      // Determine MIME type from file extension
      String contentType = 'image/jpeg'; // Default
      final extension = filename.toLowerCase().split('.').last;
      if (extension == 'png') {
        contentType = 'image/png';
      } else if (extension == 'jpg' || extension == 'jpeg') {
        contentType = 'image/jpeg';
      } else if (extension == 'gif') {
        contentType = 'image/gif';
      } else if (extension == 'webp') {
        contentType = 'image/webp';
      }
      
      request.files.add(http.MultipartFile.fromBytes(
        'profilePicture',
        bytes,
        filename: filename,
        contentType: MediaType.parse(contentType),
      ));

      print('📦 Sending multipart request...');
      print('📦 File: $filename (${bytes.length} bytes)');
      print('📦 Endpoint: ${uri.toString()}');
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📥 Upload response status: ${response.statusCode}');
      print('📦 Upload response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          final profilePictureUrl = decoded['data']['profilePicture'] as String;
          print('✅ Profile picture uploaded: $profilePictureUrl');
          return profilePictureUrl;
        } else {
          final error = decoded['error'] ?? decoded['message'] ?? 'Upload failed';
          print('❌ Upload failed: $error');
          throw Exception(error);
        }
      } else {
        // Try to parse error message from response
        String errorMsg = 'HTTP ${response.statusCode}';
        try {
          final decoded = jsonDecode(response.body);
          errorMsg = decoded['error'] ?? decoded['message'] ?? errorMsg;
        } catch (_) {
          // Response body is not JSON
        }
        print('❌ Upload failed: $errorMsg');
        throw Exception('Upload failed: $errorMsg');
      }
    } catch (e) {
      print('❌ Error uploading profile picture: $e');
      throw Exception('Error uploading profile picture: $e');
    }
  }

  /// Upload profile picture from File (legacy - for backward compatibility)
  static Future<String> uploadProfilePicture(File imageFile) async {
    try {
      print('📤 Uploading profile picture...');
      
      final token = await StorageService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final uri = Uri.parse('$baseUrl/users/profile/picture');
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token';

      // Read file as bytes (works on all platforms)
      final bytes = await imageFile.readAsBytes();
      final filename = imageFile.path.split('/').last.split('\\').last;
      
      request.files.add(http.MultipartFile.fromBytes(
        'profilePicture',
        bytes,
        filename: filename,
      ));

      print('📦 Sending multipart request...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📥 Upload response status: ${response.statusCode}');
      print('📦 Upload response body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          final profilePictureUrl = decoded['data']['profilePicture'] as String;
          print('✅ Profile picture uploaded: $profilePictureUrl');
          return profilePictureUrl;
        } else {
          throw Exception(decoded['error'] ?? 'Upload failed');
        }
      } else {
        throw Exception('Upload failed: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error uploading profile picture: $e');
      throw Exception('Error uploading profile picture: $e');
    }
  }

  /// Set profile picture via URL (alternative to upload)
  static Future<void> setProfilePictureUrl(String imageUrl) async {
    try {
      print('📤 Setting profile picture URL: $imageUrl');
      
      final response = await http.put(
        Uri.parse('$baseUrl/users/profile'),
        headers: await _getHeaders(needsAuth: true),
        body: jsonEncode({'profilePicture': imageUrl}),
      );

      if (response.statusCode == 200) {
        print('✅ Profile picture URL updated');
      } else {
        throw Exception('Failed to set profile picture: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error setting profile picture URL: $e');
      throw Exception('Error setting profile picture URL: $e');
    }
  }

  /// Fetch user badges and progress
  static Future<Map<String, dynamic>> fetchUserBadges() async {
    try {
      print('📤 Fetching user badges...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/users/badges'),
        headers: await _getHeaders(needsAuth: true),
      );

      print('📥 Badges response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        print('📦 Badges response: $decoded');
        
        if (decoded['success'] == true) {
          final data = decoded['data'] as Map<String, dynamic>;
          print('✅ Fetched badges successfully');
          return data;
        } else {
          throw Exception(decoded['error'] ?? 'Failed to fetch badges');
        }
      } else {
        throw Exception('Failed to fetch badges: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching badges: $e');
      rethrow;
    }
  }
}


