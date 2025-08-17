import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/missionary.dart';

/// Service to upload JSON data to Firestore
/// Handles conversion from JSON format to Firestore documents
class JsonDataUploader {
  static final JsonDataUploader _instance = JsonDataUploader._internal();
  factory JsonDataUploader() => _instance;
  JsonDataUploader._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'missionaries';

  /// Upload missionaries from JSON file to Firestore
  Future<UploadResult> uploadFromJsonFile(String jsonFilePath) async {
    try {
      print('📁 Reading JSON file from: $jsonFilePath');
      
      // Read the JSON file
      final file = File(jsonFilePath);
      if (!await file.exists()) {
        throw Exception('JSON file not found at: $jsonFilePath');
      }

      final jsonString = await file.readAsString();
      return await uploadFromJsonString(jsonString);
    } catch (e) {
      print('❌ Error reading JSON file: $e');
      return UploadResult(
        success: false,
        message: 'Failed to read JSON file: $e',
        uploadedCount: 0,
        errors: [e.toString()],
      );
    }
  }

  /// Upload missionaries from JSON string
  Future<UploadResult> uploadFromJsonString(String jsonString) async {
    int uploadedCount = 0;
    int skippedCount = 0;
    int updatedCount = 0;
    List<String> errors = [];
    List<String> warnings = [];

    try {
      print('📄 Parsing JSON data...');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      print('✅ Found ${jsonData.length} missionaries in JSON');

      // Process each missionary
      for (final entry in jsonData.entries) {
        try {
          final String key = entry.key;
          final Map<String, dynamic> data = entry.value as Map<String, dynamic>;
          
          print('👤 Processing: ${data['fullName'] ?? key}');

          // Convert JSON data to enhanced Firestore format
          final missionaryData = _convertJsonToFirestore(key, data);
          
          // Check if document already exists
          final docRef = _firestore.collection(_collectionName).doc(key);
          final existingDoc = await docRef.get();
          
          if (existingDoc.exists) {
            // Update existing document
            await docRef.update(missionaryData);
            updatedCount++;
            print('  ✅ Updated existing missionary: ${data['fullName']}');
          } else {
            // Create new document
            await docRef.set(missionaryData);
            uploadedCount++;
            print('  ✅ Created new missionary: ${data['fullName']}');
          }

          // Small delay to avoid rate limiting
          await Future.delayed(const Duration(milliseconds: 100));

        } catch (e) {
          final errorMsg = 'Failed to process ${entry.key}: $e';
          errors.add(errorMsg);
          print('  ❌ $errorMsg');
          continue;
        }
      }

      final success = errors.length < jsonData.length;
      final message = success 
          ? 'Upload completed! Created: $uploadedCount, Updated: $updatedCount, Errors: ${errors.length}'
          : 'Upload completed with errors. See error details.';

      print('🎉 $message');
      
      return UploadResult(
        success: success,
        message: message,
        uploadedCount: uploadedCount,
        updatedCount: updatedCount,
        skippedCount: skippedCount,
        errors: errors,
        warnings: warnings,
      );

    } catch (e) {
      final errorMsg = 'Failed to parse or upload JSON data: $e';
      print('❌ $errorMsg');
      return UploadResult(
        success: false,
        message: errorMsg,
        uploadedCount: uploadedCount,
        errors: [e.toString()],
      );
    }
  }

  /// Convert JSON missionary data to Firestore format
  Map<String, dynamic> _convertJsonToFirestore(String key, Map<String, dynamic> jsonData) {
    // Helper function to convert arrays to strings
    String _arrayToString(dynamic value) {
      if (value is List) {
        return value.join(', ');
      }
      return value?.toString() ?? '';
    }

    // Helper function to get first item from array or string
    String _getFirstFromArray(dynamic value) {
      if (value is List && value.isNotEmpty) {
        return value.first.toString();
      }
      return value?.toString() ?? '';
    }

    // Helper function to determine century from birth date
    String _determineCentury(String? birthDate) {
      if (birthDate == null || birthDate.isEmpty) return 'Unknown';
      
      try {
        final year = int.parse(birthDate.substring(0, 4));
        final century = ((year - 1) ~/ 100) + 1;
        
        // Convert number to ordinal
        String ordinal;
        switch (century) {
          case 1: ordinal = '1st'; break;
          case 2: ordinal = '2nd'; break;
          case 3: ordinal = '3rd'; break;
          default: ordinal = '${century}th'; break;
        }
        
        return '$ordinal Century';
      } catch (e) {
        return 'Unknown';
      }
    }

    // Create the base missionary data compatible with existing model
    final Map<String, dynamic> firestoreData = {
      // Required fields for existing model
      'fullName': jsonData['fullName'] ?? '',
      'heroImageUrl': jsonData['heroImageUrl'] ?? '',
      'bio': jsonData['bio'] ?? '',
      'fieldOfService': _arrayToString(jsonData['fieldOfService']),
      'countryOfService': _arrayToString(jsonData['countryOfService']),
      'century': _determineCentury(jsonData['birthDate']),
      
      // Additional rich data from JSON
      'birthDate': jsonData['birthDate'],
      'deathDate': jsonData['deathDate'],
      'placesOfWork': jsonData['placesOfWork'] ?? [],
      'quotes': jsonData['quotes'] ?? [],
      'legacy': jsonData['legacy'] ?? '',
      
      // Arrays for advanced filtering
      'countriesOfService': jsonData['countryOfService'] is List 
          ? jsonData['countryOfService'] 
          : [jsonData['countryOfService']?.toString()].where((e) => e != null).toList(),
      'fieldsOfService': jsonData['fieldOfService'] is List 
          ? jsonData['fieldOfService'] 
          : [jsonData['fieldOfService']?.toString()].where((e) => e != null).toList(),
      
      // Metadata
      'sourceKey': key,
      'dataSource': 'json_upload',
      'lastUpdated': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
      
      // Search optimization fields
      'searchKeywords': _generateSearchKeywords(jsonData),
      'tags': _generateTags(jsonData),
    };

    return firestoreData;
  }

  /// Generate search keywords for better search functionality
  List<String> _generateSearchKeywords(Map<String, dynamic> data) {
    final keywords = <String>[];
    
    // Add name parts
    if (data['fullName'] != null) {
      keywords.addAll(data['fullName'].toString().toLowerCase().split(' '));
    }
    
    // Add countries
    if (data['countryOfService'] is List) {
      keywords.addAll((data['countryOfService'] as List)
          .map((c) => c.toString().toLowerCase()));
    } else if (data['countryOfService'] != null) {
      keywords.add(data['countryOfService'].toString().toLowerCase());
    }
    
    // Add fields of service
    if (data['fieldOfService'] is List) {
      keywords.addAll((data['fieldOfService'] as List)
          .map((f) => f.toString().toLowerCase()));
    } else if (data['fieldOfService'] != null) {
      keywords.add(data['fieldOfService'].toString().toLowerCase());
    }
    
    // Add century info
    if (data['birthDate'] != null) {
      final century = _determineCentury(data['birthDate']).toLowerCase();
      keywords.add(century);
    }
    
    return keywords.toSet().toList(); // Remove duplicates
  }

  /// Generate tags for categorization
  List<String> _generateTags(Map<String, dynamic> data) {
    final tags = <String>[];
    
    // Add field-based tags
    if (data['fieldOfService'] is List) {
      tags.addAll((data['fieldOfService'] as List)
          .map((f) => f.toString()));
    } else if (data['fieldOfService'] != null) {
      tags.add(data['fieldOfService'].toString());
    }
    
    // Add geographical tags
    if (data['countryOfService'] is List) {
      tags.addAll((data['countryOfService'] as List)
          .map((c) => c.toString()));
    } else if (data['countryOfService'] != null) {
      tags.add(data['countryOfService'].toString());
    }
    
    // Add century tag
    if (data['birthDate'] != null) {
      tags.add(_determineCentury(data['birthDate']));
    }
    
    // Add special tags based on content
    final bio = data['bio']?.toString().toLowerCase() ?? '';
    if (bio.contains('martyr') || bio.contains('martyred')) {
      tags.add('Martyr');
    }
    if (bio.contains('doctor') || bio.contains('medical')) {
      tags.add('Medical');
    }
    if (bio.contains('translate') || bio.contains('translation')) {
      tags.add('Bible Translation');
    }
    if (bio.contains('orphan')) {
      tags.add('Orphan Care');
    }
    if (bio.contains('women') || bio.contains('widow')) {
      tags.add('Women\'s Ministry');
    }
    
    return tags.toSet().toList(); // Remove duplicates
  }

  /// Batch upload for better performance with large datasets
  Future<UploadResult> batchUploadFromJsonString(String jsonString, {int batchSize = 10}) async {
    int uploadedCount = 0;
    int updatedCount = 0;
    List<String> errors = [];

    try {
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final entries = jsonData.entries.toList();
      
      print('📦 Processing ${entries.length} missionaries in batches of $batchSize');

      // Process in batches
      for (int i = 0; i < entries.length; i += batchSize) {
        final batch = _firestore.batch();
        final currentBatch = entries.skip(i).take(batchSize);
        int batchUpdated = 0;
        int batchCreated = 0;

        print('📦 Processing batch ${(i ~/ batchSize) + 1}/${(entries.length / batchSize).ceil()}');

        for (final entry in currentBatch) {
          try {
            final String key = entry.key;
            final Map<String, dynamic> data = entry.value as Map<String, dynamic>;
            final missionaryData = _convertJsonToFirestore(key, data);
            
            final docRef = _firestore.collection(_collectionName).doc(key);
            final existingDoc = await docRef.get();
            
            if (existingDoc.exists) {
              batch.update(docRef, missionaryData);
              batchUpdated++;
            } else {
              batch.set(docRef, missionaryData);
              batchCreated++;
            }
          } catch (e) {
            errors.add('Failed to prepare ${entry.key}: $e');
          }
        }

        // Commit the batch
        await batch.commit();
        uploadedCount += batchCreated;
        updatedCount += batchUpdated;
        
        print('  ✅ Batch completed: Created $batchCreated, Updated $batchUpdated');
        
        // Delay between batches
        await Future.delayed(const Duration(milliseconds: 500));
      }

      final success = errors.isEmpty || errors.length < entries.length;
      final message = 'Batch upload completed! Created: $uploadedCount, Updated: $updatedCount, Errors: ${errors.length}';

      return UploadResult(
        success: success,
        message: message,
        uploadedCount: uploadedCount,
        updatedCount: updatedCount,
        errors: errors,
      );

    } catch (e) {
      return UploadResult(
        success: false,
        message: 'Batch upload failed: $e',
        uploadedCount: uploadedCount,
        errors: [e.toString()],
      );
    }
  }

  /// Backup existing data before upload
  Future<String> backupExistingData() async {
    try {
      print('💾 Creating backup of existing missionary data...');
      
      final snapshot = await _firestore.collection(_collectionName).get();
      final backupData = <String, dynamic>{};
      
      for (final doc in snapshot.docs) {
        backupData[doc.id] = doc.data();
      }
      
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final backupFileName = 'missionaries_backup_$timestamp.json';
      final backupContent = const JsonEncoder.withIndent('  ').convert(backupData);
      
      // For Flutter app, we'd typically save to app documents directory
      // This is just the backup content that can be saved
      print('✅ Backup created: $backupFileName (${snapshot.docs.length} documents)');
      
      return backupContent;
      
    } catch (e) {
      throw Exception('Failed to create backup: $e');
    }
  }

  /// Validate JSON structure before upload
  ValidationResult validateJsonStructure(String jsonString) {
    try {
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<String> warnings = [];
      final List<String> errors = [];
      int validMissionaries = 0;

      for (final entry in jsonData.entries) {
        final key = entry.key;
        final data = entry.value;

        if (data is! Map<String, dynamic>) {
          errors.add('Invalid data structure for $key');
          continue;
        }

        final missionaryData = data as Map<String, dynamic>;

        // Check required fields
        if (missionaryData['fullName'] == null || missionaryData['fullName'].toString().isEmpty) {
          errors.add('Missing fullName for $key');
        }

        if (missionaryData['heroImageUrl'] == null || missionaryData['heroImageUrl'].toString().isEmpty) {
          warnings.add('Missing heroImageUrl for $key');
        }

        // Check data types
        if (missionaryData['countryOfService'] != null && 
            missionaryData['countryOfService'] is! List && 
            missionaryData['countryOfService'] is! String) {
          warnings.add('countryOfService should be string or array for $key');
        }

        if (missionaryData['fieldOfService'] != null && 
            missionaryData['fieldOfService'] is! List && 
            missionaryData['fieldOfService'] is! String) {
          warnings.add('fieldOfService should be string or array for $key');
        }

        validMissionaries++;
      }

      return ValidationResult(
        isValid: errors.isEmpty,
        totalRecords: jsonData.length,
        validRecords: validMissionaries,
        errors: errors,
        warnings: warnings,
      );

    } catch (e) {
      return ValidationResult(
        isValid: false,
        totalRecords: 0,
        validRecords: 0,
        errors: ['Failed to parse JSON: $e'],
        warnings: [],
      );
    }
  }
}

/// Result class for upload operations
class UploadResult {
  final bool success;
  final String message;
  final int uploadedCount;
  final int updatedCount;
  final int skippedCount;
  final List<String> errors;
  final List<String> warnings;

  UploadResult({
    required this.success,
    required this.message,
    required this.uploadedCount,
    this.updatedCount = 0,
    this.skippedCount = 0,
    this.errors = const [],
    this.warnings = const [],
  });

  @override
  String toString() {
    return 'UploadResult(success: $success, uploaded: $uploadedCount, updated: $updatedCount, errors: ${errors.length})';
  }
}

/// Result class for validation operations
class ValidationResult {
  final bool isValid;
  final int totalRecords;
  final int validRecords;
  final List<String> errors;
  final List<String> warnings;

  ValidationResult({
    required this.isValid,
    required this.totalRecords,
    required this.validRecords,
    required this.errors,
    required this.warnings,
  });

  @override
  String toString() {
    return 'ValidationResult(valid: $isValid, records: $validRecords/$totalRecords, errors: ${errors.length}, warnings: ${warnings.length})';
  }
}