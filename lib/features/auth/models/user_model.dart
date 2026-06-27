class UserModel {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final String? phone;
  final String? location;
  final String? bio;
  final String? profileImage;
  final String? specialty;
  final bool isVerified;
  final String? createdAt;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    this.phone,
    this.location,
    this.bio,
    this.profileImage,
    this.specialty,
    this.isVerified = false,
    this.createdAt,
  });

  // Full name getter
  String get fullName => '$firstName $lastName';

  // Is technician getter
  bool get isTechnician => role == 'technician';

  // Is customer getter
  bool get isCustomer => role == 'customer';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'customer',
      phone: json['phone'],
      location: json['location'],
      bio: json['bio'],
      profileImage: json['profileImage'],
      specialty: json['specialty'],
      isVerified: json['isVerified'] ?? false,
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'role': role,
      'phone': phone,
      'location': location,
      'bio': bio,
      'profileImage': profileImage,
      'specialty': specialty,
      'isVerified': isVerified,
      'createdAt': createdAt,
    };
  }

  UserModel copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? email,
    String? role,
    String? phone,
    String? location,
    String? bio,
    String? profileImage,
    String? specialty,
    bool? isVerified,
    String? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      bio: bio ?? this.bio,
      profileImage: profileImage ?? this.profileImage,
      specialty: specialty ?? this.specialty,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}