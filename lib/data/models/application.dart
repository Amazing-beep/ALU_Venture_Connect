enum ApplicationStatus {
  applied,
  underReview,
  shortlisted,
  interview,
  accepted,
  closed
}

extension ApplicationStatusExtension on ApplicationStatus {
  String toReadableString() {
    switch (this) {
      case ApplicationStatus.applied:
        return 'Applied';
      case ApplicationStatus.underReview:
        return 'Under Review';
      case ApplicationStatus.shortlisted:
        return 'Shortlisted';
      case ApplicationStatus.interview:
        return 'Interview';
      case ApplicationStatus.accepted:
        return 'Accepted';
      case ApplicationStatus.closed:
        return 'Closed';
    }
  }

  static ApplicationStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'applied':
        return ApplicationStatus.applied;
      case 'underreview':
      case 'under review':
        return ApplicationStatus.underReview;
      case 'shortlisted':
        return ApplicationStatus.shortlisted;
      case 'interview':
        return ApplicationStatus.interview;
      case 'accepted':
        return ApplicationStatus.accepted;
      case 'closed':
        return ApplicationStatus.closed;
      default:
        return ApplicationStatus.applied;
    }
  }
}

class Application {
  final String id;
  final String opportunityId;
  final String opportunityTitle;
  final String companyName;
  final String? companyLogoUrl;
  final String studentId;
  final String studentName;
  final DateTime appliedDate;
  final ApplicationStatus status;
  final String? coverLetter;

  Application({
    required this.id,
    required this.opportunityId,
    required this.opportunityTitle,
    required this.companyName,
    this.companyLogoUrl,
    required this.studentId,
    required this.studentName,
    required this.appliedDate,
    required this.status,
    this.coverLetter,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'opportunityId': opportunityId,
      'opportunityTitle': opportunityTitle,
      'companyName': companyName,
      'companyLogoUrl': companyLogoUrl,
      'studentId': studentId,
      'studentName': studentName,
      'appliedDate': appliedDate.toIso8601String(),
      'status': status.toString().split('.').last,
      'coverLetter': coverLetter,
    };
  }

  factory Application.fromMap(Map<String, dynamic> map) {
    return Application(
      id: map['id'] ?? '',
      opportunityId: map['opportunityId'] ?? '',
      opportunityTitle: map['opportunityTitle'] ?? '',
      companyName: map['companyName'] ?? '',
      companyLogoUrl: map['companyLogoUrl'],
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      appliedDate: map['appliedDate'] != null 
          ? DateTime.parse(map['appliedDate']) 
          : DateTime.now(),
      status: ApplicationStatusExtension.fromString(map['status'] ?? 'applied'),
      coverLetter: map['coverLetter'],
    );
  }

  Application copyWith({
    String? id,
    String? opportunityId,
    String? opportunityTitle,
    String? companyName,
    String? companyLogoUrl,
    String? studentId,
    String? studentName,
    DateTime? appliedDate,
    ApplicationStatus? status,
    String? coverLetter,
  }) {
    return Application(
      id: id ?? this.id,
      opportunityId: opportunityId ?? this.opportunityId,
      opportunityTitle: opportunityTitle ?? this.opportunityTitle,
      companyName: companyName ?? this.companyName,
      companyLogoUrl: companyLogoUrl ?? this.companyLogoUrl,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      appliedDate: appliedDate ?? this.appliedDate,
      status: status ?? this.status,
      coverLetter: coverLetter ?? this.coverLetter,
    );
  }
}
