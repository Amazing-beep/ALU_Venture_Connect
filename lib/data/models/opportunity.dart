class Opportunity {
  final String id;
  final String title;
  final String company;
  final String? companyLogoUrl;
  final String location; // 'Remote', 'On-campus', 'Kigali', etc.
  final String hoursPerWeek; // e.g. '4-6 hrs/week'
  final DateTime postedDate;
  final String category; // 'Design', 'Engineering', 'Marketing', 'Data', 'Other'
  final String description;
  final List<String> skills; // e.g. ['Flutter', 'Dart', 'Problem Solving']
  final List<String> tags; // e.g. ['UX Design', 'Research', 'Remote']
  final String postedBy; // UserProfile ID of startup

  Opportunity({
    required this.id,
    required this.title,
    required this.company,
    this.companyLogoUrl,
    required this.location,
    required this.hoursPerWeek,
    required this.postedDate,
    required this.category,
    required this.description,
    required this.skills,
    required this.tags,
    required this.postedBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'company': company,
      'companyLogoUrl': companyLogoUrl,
      'location': location,
      'hoursPerWeek': hoursPerWeek,
      'postedDate': postedDate.toIso8601String(),
      'category': category,
      'description': description,
      'skills': skills,
      'tags': tags,
      'postedBy': postedBy,
    };
  }

  factory Opportunity.fromMap(Map<String, dynamic> map) {
    return Opportunity(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      company: map['company'] ?? '',
      companyLogoUrl: map['companyLogoUrl'],
      location: map['location'] ?? 'Remote',
      hoursPerWeek: map['hoursPerWeek'] ?? '',
      postedDate: map['postedDate'] != null 
          ? DateTime.parse(map['postedDate']) 
          : DateTime.now(),
      category: map['category'] ?? 'Other',
      description: map['description'] ?? '',
      skills: List<String>.from(map['skills'] ?? []),
      tags: List<String>.from(map['tags'] ?? []),
      postedBy: map['postedBy'] ?? '',
    );
  }
}
