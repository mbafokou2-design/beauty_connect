class TechnicianSearchResult {
  final int id;
  final String firstName;
  final String lastName;
  final String? specialty;
  final String? profileImage;
  final String? location;
  final double rating;

  TechnicianSearchResult({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.specialty,
    this.profileImage,
    this.location,
    this.rating = 0,
  });

  String get fullName => '$firstName $lastName';

  factory TechnicianSearchResult.fromJson(Map<String, dynamic> json) {
    return TechnicianSearchResult(
      id: json['id'],
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      specialty: json['specialty'],
      profileImage: json['profileImage'],
      location: json['location'],
      rating: 0,
    );
  }
}