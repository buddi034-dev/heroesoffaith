import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/missionary.dart';

/// Service class for handling Firestore database operations
/// Provides CRUD operations for missionaries and other collections
class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection names
  static const String _missionariesCollection = 'missionaries';
  static const String _usersCollection = 'users';
  static const String _timelineEventsCollection = 'timelineEvents';
  static const String _mediaCollection = 'media';
  static const String _favoritesCollection = 'favorites';

  /// Get reference to missionaries collection
  CollectionReference get missionariesRef => _firestore.collection(_missionariesCollection);

  /// Get reference to users collection
  CollectionReference get usersRef => _firestore.collection(_usersCollection);

  // MISSIONARY OPERATIONS

  /// Get all missionaries as a stream
  Stream<List<Missionary>> getMissionariesStream({int? limit}) {
    Query query = missionariesRef.orderBy('fullName');
    if (limit != null) {
      query = query.limit(limit);
    }
    
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Missionary.fromFirestore(doc)).toList();
    });
  }

  /// Get all missionaries as a future
  Future<List<Missionary>> getMissionaries({int? limit}) async {
    try {
      Query query = missionariesRef.orderBy('fullName');
      if (limit != null) {
        query = query.limit(limit);
      }
      
      final snapshot = await query.get();
      return snapshot.docs.map((doc) => Missionary.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting missionaries: $e');
      throw Exception('Failed to fetch missionaries: $e');
    }
  }

  /// Get a single missionary by ID
  Future<Missionary?> getMissionaryById(String id) async {
    try {
      final doc = await missionariesRef.doc(id).get();
      if (doc.exists) {
        return Missionary.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting missionary by ID: $e');
      throw Exception('Failed to fetch missionary: $e');
    }
  }

  /// Search missionaries by name or other fields
  Stream<List<Missionary>> searchMissionaries(String searchTerm) {
    if (searchTerm.isEmpty) {
      return getMissionariesStream();
    }

    // For basic text search - Firestore doesn't support full-text search natively
    // This will search for names that start with the search term
    final String searchLower = searchTerm.toLowerCase();
    final String searchUpper = searchTerm.toUpperCase();
    
    return missionariesRef
        .where('fullName', isGreaterThanOrEqualTo: searchTerm)
        .where('fullName', isLessThan: searchTerm + 'z')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Missionary.fromFirestore(doc))
          .where((missionary) {
            final name = missionary.fullName.toLowerCase();
            final bio = missionary.bio?.toLowerCase() ?? '';
            final field = missionary.fieldOfService?.toLowerCase() ?? '';
            final country = missionary.countryOfService?.toLowerCase() ?? '';
            final century = missionary.century?.toLowerCase() ?? '';
            
            return name.contains(searchLower) ||
                   bio.contains(searchLower) ||
                   field.contains(searchLower) ||
                   country.contains(searchLower) ||
                   century.contains(searchLower);
          })
          .toList();
    });
  }

  /// Create a new missionary
  Future<String> createMissionary(Missionary missionary) async {
    try {
      final docRef = await missionariesRef.add(missionary.toMap());
      print('Missionary created with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Error creating missionary: $e');
      throw Exception('Failed to create missionary: $e');
    }
  }

  /// Update an existing missionary
  Future<void> updateMissionary(String id, Missionary missionary) async {
    try {
      await missionariesRef.doc(id).update(missionary.toMap());
      print('Missionary updated successfully: $id');
    } catch (e) {
      print('Error updating missionary: $e');
      throw Exception('Failed to update missionary: $e');
    }
  }

  /// Update specific fields of a missionary
  Future<void> updateMissionaryFields(String id, Map<String, dynamic> fields) async {
    try {
      // Add timestamp to track updates
      fields['lastUpdated'] = FieldValue.serverTimestamp();
      
      await missionariesRef.doc(id).update(fields);
      print('Missionary fields updated successfully: $id');
    } catch (e) {
      print('Error updating missionary fields: $e');
      throw Exception('Failed to update missionary fields: $e');
    }
  }

  /// Delete a missionary
  Future<void> deleteMissionary(String id) async {
    try {
      await missionariesRef.doc(id).delete();
      print('Missionary deleted successfully: $id');
    } catch (e) {
      print('Error deleting missionary: $e');
      throw Exception('Failed to delete missionary: $e');
    }
  }

  /// Set or overwrite a missionary document
  Future<void> setMissionary(String id, Missionary missionary) async {
    try {
      await missionariesRef.doc(id).set(missionary.toMap());
      print('Missionary set successfully: $id');
    } catch (e) {
      print('Error setting missionary: $e');
      throw Exception('Failed to set missionary: $e');
    }
  }

  // BATCH OPERATIONS

  /// Batch update multiple missionaries
  Future<void> batchUpdateMissionaries(Map<String, Missionary> missionaryUpdates) async {
    try {
      final batch = _firestore.batch();
      
      missionaryUpdates.forEach((id, missionary) {
        batch.update(missionariesRef.doc(id), missionary.toMap());
      });
      
      await batch.commit();
      print('Batch update completed for ${missionaryUpdates.length} missionaries');
    } catch (e) {
      print('Error in batch update: $e');
      throw Exception('Failed to batch update missionaries: $e');
    }
  }

  /// Batch create multiple missionaries
  Future<List<String>> batchCreateMissionaries(List<Missionary> missionaries) async {
    try {
      final batch = _firestore.batch();
      final List<String> newIds = [];
      
      for (final missionary in missionaries) {
        final docRef = missionariesRef.doc(); // Generate new doc reference
        batch.set(docRef, missionary.toMap());
        newIds.add(docRef.id);
      }
      
      await batch.commit();
      print('Batch create completed for ${missionaries.length} missionaries');
      return newIds;
    } catch (e) {
      print('Error in batch create: $e');
      throw Exception('Failed to batch create missionaries: $e');
    }
  }

  // FILTERING AND QUERYING

  /// Get missionaries by country
  Stream<List<Missionary>> getMissionariesByCountry(String country) {
    return missionariesRef
        .where('countryOfService', isEqualTo: country)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Missionary.fromFirestore(doc)).toList();
    });
  }

  /// Get missionaries by century
  Stream<List<Missionary>> getMissionariesByCentury(String century) {
    return missionariesRef
        .where('century', isEqualTo: century)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Missionary.fromFirestore(doc)).toList();
    });
  }

  /// Get missionaries by field of service
  Stream<List<Missionary>> getMissionariesByField(String fieldOfService) {
    return missionariesRef
        .where('fieldOfService', isEqualTo: fieldOfService)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Missionary.fromFirestore(doc)).toList();
    });
  }

  // UTILITY METHODS

  /// Check if a missionary exists
  Future<bool> missionaryExists(String id) async {
    try {
      final doc = await missionariesRef.doc(id).get();
      return doc.exists;
    } catch (e) {
      print('Error checking missionary existence: $e');
      return false;
    }
  }

  /// Get document count in missionaries collection
  Future<int> getMissionariesCount() async {
    try {
      final snapshot = await missionariesRef.count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      print('Error getting missionaries count: $e');
      return 0;
    }
  }

  /// Remove specific field from a missionary document
  Future<void> removeMissionaryField(String id, String fieldName) async {
    try {
      await missionariesRef.doc(id).update({
        fieldName: FieldValue.delete(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      print('Field $fieldName removed from missionary: $id');
    } catch (e) {
      print('Error removing missionary field: $e');
      throw Exception('Failed to remove missionary field: $e');
    }
  }

  // TRANSACTION OPERATIONS

  /// Update missionary within a transaction
  Future<void> updateMissionaryTransaction(String id, Missionary missionary) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final docRef = missionariesRef.doc(id);
        final snapshot = await transaction.get(docRef);
        
        if (!snapshot.exists) {
          throw Exception('Missionary not found');
        }
        
        transaction.update(docRef, missionary.toMap());
      });
      print('Missionary updated in transaction: $id');
    } catch (e) {
      print('Error in transaction update: $e');
      throw Exception('Failed to update missionary in transaction: $e');
    }
  }

  // REAL-TIME LISTENER FOR SINGLE DOCUMENT

  /// Listen to changes for a single missionary
  Stream<Missionary?> getMissionaryStream(String id) {
    return missionariesRef.doc(id).snapshots().map((doc) {
      if (doc.exists) {
        return Missionary.fromFirestore(doc);
      }
      return null;
    });
  }

  // ERROR HANDLING UTILITY

  /// Handle Firestore errors gracefully
  String _getFirestoreErrorMessage(dynamic error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'Permission denied. Please check your access rights.';
        case 'unavailable':
          return 'Service is currently unavailable. Please try again later.';
        case 'not-found':
          return 'The requested document was not found.';
        case 'already-exists':
          return 'A document with this ID already exists.';
        case 'resource-exhausted':
          return 'Resource limits exceeded. Please try again later.';
        case 'cancelled':
          return 'Operation was cancelled.';
        case 'deadline-exceeded':
          return 'Operation timed out. Please try again.';
        default:
          return 'An error occurred: ${error.message}';
      }
    }
    return 'An unexpected error occurred: $error';
  }
}