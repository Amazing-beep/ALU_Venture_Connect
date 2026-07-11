enum UserRole { student, startup }

class UserProfile {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final String? profilePictureUrl;
  
  // Student-specific fields
  final String? location;
  final List<String>? skills;
  final String? bio;
  
  // Startup-specific fields
  final String? startupName;
  final String? registrationNumber; // For ALU verification
  final bool isVerified; // True if verified by ALU admin
  final String? startupDescription;

  UserProfile({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.profilePictureUrl,
    this.location,
    this.skills,
    this.bio,
    this.startupName,
    this.registrationNumber,
    this.isVerified = false,
    this.startupDescription,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role.toString().split('.').last,
      'profilePictureUrl': profilePictureUrl,
      'location': location,
      'skills': skills,
      'bio': bio,
      'startupName': startupName,
      'registrationNumber': registrationNumber,
      'isVerified': isVerified,
      'startupDescription': startupDescription,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] == 'startup' ? UserRole.startup : UserRole.student,
      profilePictureUrl: map['profilePictureUrl'],
      location: map['location'],
      skills: map['skills'] != null ? List<String>.from(map['skills']) : null,
      bio: map['bio'],
      startupName: map['startupName'],
      registrationNumber: map['registrationNumber'],
      isVerified: map['isVerified'] ?? false,
      startupDescription: map['startupDescription'],
    );
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? name,
    UserRole? role,
    String? profilePictureUrl,
    String? location,
    List<String>? skills,
    String? bio,
    String? startupName,
    String? registrationNumber,
    bool? isVerified,
    String? startupDescription,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      location: location ?? this.location,
      skills: skills ?? this.skills,
      bio: bio ?? this.bio,
      startupName: startupName ?? this.startupName,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      isVerified: isVerified ?? this.isVerified,
      startupDescription: startupDescription ?? this.startupDescription,
    );
  }
}
