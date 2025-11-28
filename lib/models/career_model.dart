/// Philippine IT Salary Data (Monthly, in PHP)
/// Source: Industry standards for 2024-2025
class SalaryData {
  final String entryLevel;      // 0-2 years
  final String intermediate;    // 3-5 years
  final String seniorLevel;     // 5+ years

  const SalaryData({
    required this.entryLevel,
    required this.intermediate,
    required this.seniorLevel,
  });

  /// Get salary range as a simple string (for backward compatibility)
  String get simpleRange => '$entryLevel - $seniorLevel';
}

/// Philippine IT Salary Database
class PhilippineITSalaries {
  static const Map<String, SalaryData> _salaryDatabase = {
    'business analyst': SalaryData(
      entryLevel: '₱25,000 - ₱35,000',
      intermediate: '₱40,000 - ₱60,000',
      seniorLevel: '₱70,000 - ₱100,000+',
    ),
    'cloud engineer': SalaryData(
      entryLevel: '₱35,000 - ₱50,000',
      intermediate: '₱60,000 - ₱90,000',
      seniorLevel: '₱110,000 - ₱180,000',
    ),
    'cybersecurity analyst': SalaryData(
      entryLevel: '₱30,000 - ₱45,000',
      intermediate: '₱50,000 - ₱80,000',
      seniorLevel: '₱90,000 - ₱150,000',
    ),
    'cybersecurity': SalaryData(
      entryLevel: '₱30,000 - ₱45,000',
      intermediate: '₱50,000 - ₱80,000',
      seniorLevel: '₱90,000 - ₱150,000',
    ),
    'data analyst': SalaryData(
      entryLevel: '₱23,000 - ₱35,000',
      intermediate: '₱40,000 - ₱65,000',
      seniorLevel: '₱70,000 - ₱110,000',
    ),
    'data engineer': SalaryData(
      entryLevel: '₱40,000 - ₱60,000',
      intermediate: '₱70,000 - ₱110,000',
      seniorLevel: '₱130,000 - ₱200,000+',
    ),
    'data scientist': SalaryData(
      entryLevel: '₱40,000 - ₱60,000',
      intermediate: '₱70,000 - ₱100,000',
      seniorLevel: '₱120,000 - ₱250,000',
    ),
    'data science': SalaryData(
      entryLevel: '₱40,000 - ₱60,000',
      intermediate: '₱70,000 - ₱100,000',
      seniorLevel: '₱120,000 - ₱250,000',
    ),
    'devops engineer': SalaryData(
      entryLevel: '₱40,000 - ₱60,000',
      intermediate: '₱70,000 - ₱110,000',
      seniorLevel: '₱120,000 - ₱200,000+',
    ),
    'devops': SalaryData(
      entryLevel: '₱40,000 - ₱60,000',
      intermediate: '₱70,000 - ₱110,000',
      seniorLevel: '₱120,000 - ₱200,000+',
    ),
    'full stack developer': SalaryData(
      entryLevel: '₱25,000 - ₱40,000',
      intermediate: '₱50,000 - ₱80,000',
      seniorLevel: '₱90,000 - ₱160,000',
    ),
    'full-stack developer': SalaryData(
      entryLevel: '₱25,000 - ₱40,000',
      intermediate: '₱50,000 - ₱80,000',
      seniorLevel: '₱90,000 - ₱160,000',
    ),
    'game developer': SalaryData(
      entryLevel: '₱18,000 - ₱25,000',
      intermediate: '₱30,000 - ₱55,000',
      seniorLevel: '₱70,000 - ₱100,000',
    ),
    'game development': SalaryData(
      entryLevel: '₱18,000 - ₱25,000',
      intermediate: '₱30,000 - ₱55,000',
      seniorLevel: '₱70,000 - ₱100,000',
    ),
    'it project manager': SalaryData(
      entryLevel: '₱45,000 - ₱60,000',
      intermediate: '₱70,000 - ₱90,000',
      seniorLevel: '₱100,000 - ₱160,000',
    ),
    'project manager': SalaryData(
      entryLevel: '₱45,000 - ₱60,000',
      intermediate: '₱70,000 - ₱90,000',
      seniorLevel: '₱100,000 - ₱160,000',
    ),
    'it support specialist': SalaryData(
      entryLevel: '₱18,000 - ₱25,000',
      intermediate: '₱30,000 - ₱45,000',
      seniorLevel: '₱55,000 - ₱80,000',
    ),
    'it support': SalaryData(
      entryLevel: '₱18,000 - ₱25,000',
      intermediate: '₱30,000 - ₱45,000',
      seniorLevel: '₱55,000 - ₱80,000',
    ),
    'mobile app developer': SalaryData(
      entryLevel: '₱20,000 - ₱35,000',
      intermediate: '₱40,000 - ₱70,000',
      seniorLevel: '₱80,000 - ₱130,000',
    ),
    'mobile developer': SalaryData(
      entryLevel: '₱20,000 - ₱35,000',
      intermediate: '₱40,000 - ₱70,000',
      seniorLevel: '₱80,000 - ₱130,000',
    ),
    'mobile development': SalaryData(
      entryLevel: '₱20,000 - ₱35,000',
      intermediate: '₱40,000 - ₱70,000',
      seniorLevel: '₱80,000 - ₱130,000',
    ),
    'network administrator': SalaryData(
      entryLevel: '₱20,000 - ₱30,000',
      intermediate: '₱35,000 - ₱55,000',
      seniorLevel: '₱65,000 - ₱100,000',
    ),
    'network admin': SalaryData(
      entryLevel: '₱20,000 - ₱30,000',
      intermediate: '₱35,000 - ₱55,000',
      seniorLevel: '₱65,000 - ₱100,000',
    ),
    'qa engineer': SalaryData(
      entryLevel: '₱20,000 - ₱30,000',
      intermediate: '₱35,000 - ₱60,000',
      seniorLevel: '₱70,000 - ₱110,000',
    ),
    'quality assurance': SalaryData(
      entryLevel: '₱20,000 - ₱30,000',
      intermediate: '₱35,000 - ₱60,000',
      seniorLevel: '₱70,000 - ₱110,000',
    ),
    'software engineer': SalaryData(
      entryLevel: '₱25,000 - ₱40,000',
      intermediate: '₱50,000 - ₱85,000',
      seniorLevel: '₱90,000 - ₱150,000',
    ),
    'software developer': SalaryData(
      entryLevel: '₱25,000 - ₱40,000',
      intermediate: '₱50,000 - ₱85,000',
      seniorLevel: '₱90,000 - ₱150,000',
    ),
    'software development': SalaryData(
      entryLevel: '₱25,000 - ₱40,000',
      intermediate: '₱50,000 - ₱85,000',
      seniorLevel: '₱90,000 - ₱150,000',
    ),
    'ui/ux designer': SalaryData(
      entryLevel: '₱22,000 - ₱35,000',
      intermediate: '₱40,000 - ₱65,000',
      seniorLevel: '₱80,000 - ₱120,000',
    ),
    'ui ux designer': SalaryData(
      entryLevel: '₱22,000 - ₱35,000',
      intermediate: '₱40,000 - ₱65,000',
      seniorLevel: '₱80,000 - ₱120,000',
    ),
    'ux designer': SalaryData(
      entryLevel: '₱22,000 - ₱35,000',
      intermediate: '₱40,000 - ₱65,000',
      seniorLevel: '₱80,000 - ₱120,000',
    ),
    'ui designer': SalaryData(
      entryLevel: '₱22,000 - ₱35,000',
      intermediate: '₱40,000 - ₱65,000',
      seniorLevel: '₱80,000 - ₱120,000',
    ),
    'web developer': SalaryData(
      entryLevel: '₱20,000 - ₱30,000',
      intermediate: '₱35,000 - ₱60,000',
      seniorLevel: '₱70,000 - ₱110,000',
    ),
    'web development': SalaryData(
      entryLevel: '₱20,000 - ₱30,000',
      intermediate: '₱35,000 - ₱60,000',
      seniorLevel: '₱70,000 - ₱110,000',
    ),
    'frontend developer': SalaryData(
      entryLevel: '₱20,000 - ₱30,000',
      intermediate: '₱35,000 - ₱60,000',
      seniorLevel: '₱70,000 - ₱110,000',
    ),
    'backend developer': SalaryData(
      entryLevel: '₱25,000 - ₱40,000',
      intermediate: '₱50,000 - ₱80,000',
      seniorLevel: '₱90,000 - ₱150,000',
    ),
    'machine learning engineer': SalaryData(
      entryLevel: '₱40,000 - ₱60,000',
      intermediate: '₱70,000 - ₱110,000',
      seniorLevel: '₱130,000 - ₱220,000',
    ),
    'ai engineer': SalaryData(
      entryLevel: '₱40,000 - ₱60,000',
      intermediate: '₱70,000 - ₱110,000',
      seniorLevel: '₱130,000 - ₱250,000',
    ),
    'artificial intelligence': SalaryData(
      entryLevel: '₱40,000 - ₱60,000',
      intermediate: '₱70,000 - ₱110,000',
      seniorLevel: '₱130,000 - ₱250,000',
    ),
  };

  /// Get salary data for a career title (case-insensitive matching)
  static SalaryData? getSalaryData(String careerTitle) {
    final normalizedTitle = careerTitle.toLowerCase().trim();
    
    // Direct match
    if (_salaryDatabase.containsKey(normalizedTitle)) {
      return _salaryDatabase[normalizedTitle];
    }
    
    // Partial match - find key that contains the title or vice versa
    for (final entry in _salaryDatabase.entries) {
      if (normalizedTitle.contains(entry.key) || entry.key.contains(normalizedTitle)) {
        return entry.value;
      }
    }
    
    return null;
  }

  /// Get default salary data for unknown careers
  static SalaryData get defaultSalary => const SalaryData(
    entryLevel: '₱20,000 - ₱35,000',
    intermediate: '₱40,000 - ₱70,000',
    seniorLevel: '₱80,000 - ₱130,000',
  );
}

class Career {
  final String id;
  final String title;
  final String description;
  final String salaryRange;
  final List<String> skillsRequired;
  final List<Map<String, dynamic>>? roadmap;

  Career({
    required this.id,
    required this.title,
    required this.description,
    required this.salaryRange,
    this.skillsRequired = const [],
    this.roadmap,
  });

  /// Get detailed Philippine salary data for this career
  SalaryData get philippineSalary {
    return PhilippineITSalaries.getSalaryData(title) ?? PhilippineITSalaries.defaultSalary;
  }

  factory Career.fromJson(Map<String, dynamic> json) {
    // Parse skillsRequired - handle various formats
    List<String> skills = [];
    if (json['skillsRequired'] != null) {
      if (json['skillsRequired'] is List) {
        skills = (json['skillsRequired'] as List)
            .map((s) => s.toString())
            .toList();
      }
    }

    // Parse roadmap
    List<Map<String, dynamic>>? roadmapData;
    if (json['roadmap'] != null && json['roadmap'] is List) {
      roadmapData = (json['roadmap'] as List)
          .map((r) => r as Map<String, dynamic>)
          .toList();
    }

    return Career(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      salaryRange: json['salaryRange'] ?? 'Salary not specified',
      skillsRequired: skills,
      roadmap: roadmapData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'salaryRange': salaryRange,
      'skillsRequired': skillsRequired,
      'roadmap': roadmap,
    };
  }

  /// Get skill count for preview display
  int get skillCount => skillsRequired.length;

  /// Check if career has skills defined
  bool get hasSkills => skillsRequired.isNotEmpty;
}
