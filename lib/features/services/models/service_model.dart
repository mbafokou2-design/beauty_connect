class ServiceModel {
  final int id;
  final String name;
  final String description;
  final double price;
  final int durationMinutes;
  final String category;
  final String? imageUrl;
  final bool isAvailable;
  final int technicianId;
  final TechnicianInfo? technician;

  ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationMinutes,
    required this.category,
    this.imageUrl,
    this.isAvailable = true,
    required this.technicianId,
    this.technician,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0,
      durationMinutes: json['durationMinutes'] ?? 0,
      category: json['category'] ?? '',
      imageUrl: json['imageUrl'],
      isAvailable: json['isAvailable'] ?? true,
      technicianId: json['technicianId'],
      technician: json['technician'] != null
          ? TechnicianInfo.fromJson(json['technician'])
          : null,
    );
  }
}

class TechnicianInfo {
  final int id;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? location;
  final String? profileImage;
  final String? specialty;

  TechnicianInfo({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.location,
    this.profileImage,
    this.specialty,
  });

  String get fullName => '$firstName $lastName';

  factory TechnicianInfo.fromJson(Map<String, dynamic> json) {
    return TechnicianInfo(
      id: json['id'],
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      phone: json['phone'],
      location: json['location'],
      profileImage: json['profileImage'],
      specialty: json['specialty'],
    );
  }
}