import 'package:cloud_firestore/cloud_firestore.dart';

class Missionary {
  final String id;
  final String fullName;
  final String heroImageUrl;
  final String? bio; // New field
  final String? fieldOfService; // New field
  final String? countryOfService; // New field
  final String? century; // Century when missionary served (17th, 18th, 19th, 20th)

  Missionary({
    required this.id,
    required this.fullName,
    required this.heroImageUrl,
    this.bio, // Added to constructor
    this.fieldOfService, // Added to constructor
    this.countryOfService, // Added to constructor
    this.century, // Added to constructor
  });

  factory Missionary.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Missionary(
      id: doc.id,
      fullName: data['fullName'] ?? '',
      heroImageUrl: data['heroImageUrl'] ?? '',
      bio: data['bio'] as String? ?? '', // Read 'bio', default to empty string
      fieldOfService: data['fieldOfService'] as String? ?? '', // Read 'fieldOfService', default to empty string
      countryOfService: data['countryOfService'] as String? ?? '', // Read 'countryOfService', default to empty string
      century: data['century'] as String? ?? '', // Read 'century', default to empty string
    );
  }

  // Convert Missionary object to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'heroImageUrl': heroImageUrl,
      'bio': bio,
      'fieldOfService': fieldOfService,
      'countryOfService': countryOfService,
      'century': century,
      'lastUpdated': FieldValue.serverTimestamp(),
    };
  }

  // Create a copy of the missionary with updated fields
  Missionary copyWith({
    String? id,
    String? fullName,
    String? heroImageUrl,
    String? bio,
    String? fieldOfService,
    String? countryOfService,
    String? century,
  }) {
    return Missionary(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      heroImageUrl: heroImageUrl ?? this.heroImageUrl,
      bio: bio ?? this.bio,
      fieldOfService: fieldOfService ?? this.fieldOfService,
      countryOfService: countryOfService ?? this.countryOfService,
      century: century ?? this.century,
    );
  }
}
