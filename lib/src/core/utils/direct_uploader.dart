import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Direct uploader that avoids context issues
class DirectUploader {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// Test upload with just one missionary
  static void showTestUpload(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('🧪 Test Upload'),
        content: const Text('Upload just William Carey as a test?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _performTestUpload(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Test Upload'),
          ),
        ],
      ),
    );
  }
  
  static void _performTestUpload(BuildContext context) {
    _uploadSingleMissionary().then((success) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (resultContext) => AlertDialog(
            title: Text(success ? '✅ Test Success!' : '❌ Test Failed'),
            content: Text(success 
              ? 'William Carey uploaded successfully! Check Firebase Console.'
              : 'Test upload failed. Check console for errors.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(resultContext).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }).catchError((error) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (errorContext) => AlertDialog(
            title: const Text('❌ Test Error'),
            content: Text('Test failed: $error'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(errorContext).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    });
  }
  
  static Future<bool> _uploadSingleMissionary() async {
    try {
      print('🧪 Testing single missionary upload...');
      
      final testData = {
        'fullName': 'William Carey',
        'heroImageUrl': 'https://upload.wikimedia.org/wikipedia/commons/d/d6/William_Carey.jpg',
        'bio': 'William Carey (1761–1834), known as the \'Father of Modern Missions\', was an English Baptist missionary to India.',
        'fieldOfService': 'Bible translation, Education, Social reform',
        'countryOfService': 'India',
        'century': '18th Century',
        'birthDate': '1761-08-17',
        'deathDate': '1834-06-09',
        'placesOfWork': ['Serampore', 'Calcutta'],
        'quotes': ['Expect great things from God; attempt great things for God.'],
        'legacy': 'Bible translator, educator, and social reformer in India.',
        'sourceKey': 'williamCarey',
        'lastUpdated': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      };
      
      await _firestore.collection('missionaries').doc('williamCarey').set(testData);
      print('✅ Test upload successful!');
      return true;
      
    } catch (e) {
      print('❌ Test upload failed: $e');
      return false;
    }
  }
  
  /// Simple, direct upload without complex UI
  static void showDirectUpload(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('🚀 Upload Missionaries'),
        content: const Text('Ready to upload 28 missionaries to Firestore?\n\n• William Carey\n• Mother Teresa\n• Amy Carmichael\n• And 25 more heroes of faith'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _performAllUpload(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Upload All'),
          ),
        ],
      ),
    );
  }
  
  static void _performAllUpload(BuildContext context) {
    _uploadAllMissionaries().then((success) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (resultContext) => AlertDialog(
            title: Text(success ? '✅ Upload Success!' : '❌ Upload Failed'),
            content: Text(success 
              ? 'All 28 missionaries uploaded successfully! Check Firebase Console.'
              : 'Upload failed. Check console for errors.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(resultContext).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }).catchError((error) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (errorContext) => AlertDialog(
            title: const Text('❌ Upload Error'),
            content: Text('Upload failed: $error'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(errorContext).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    });
  }
  
  static Future<bool> _uploadAllMissionaries() async {
    try {
      print('🚀 Starting upload of all missionaries...');
      
      // Load missionary data from assets
      final jsonString = await rootBundle.loadString('assets/data/missionaries.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      print('📁 Loaded ${jsonData.length} missionaries');
      
      int uploadedCount = 0;
      
      // Upload each missionary
      for (final entry in jsonData.entries) {
        try {
          final String key = entry.key;
          final Map<String, dynamic> data = entry.value as Map<String, dynamic>;
          
          // Convert to Firestore format
          final missionaryData = {
            'fullName': data['fullName'] ?? '',
            'heroImageUrl': data['heroImageUrl'] ?? '',
            'bio': data['bio'] ?? '',
            'fieldOfService': _arrayToString(data['fieldOfService']),
            'countryOfService': _arrayToString(data['countryOfService']),
            'century': _determineCentury(data['birthDate']),
            'birthDate': data['birthDate'],
            'deathDate': data['deathDate'],
            'placesOfWork': data['placesOfWork'] ?? [],
            'quotes': data['quotes'] ?? [],
            'legacy': data['legacy'] ?? '',
            'sourceKey': key,
            'lastUpdated': FieldValue.serverTimestamp(),
            'createdAt': FieldValue.serverTimestamp(),
          };
          
          // Upload to Firestore
          await _firestore.collection('missionaries').doc(key).set(missionaryData);
          uploadedCount++;
          print('  ✅ Uploaded: ${data['fullName']}');
          
          // Small delay
          await Future.delayed(const Duration(milliseconds: 50));
          
        } catch (e) {
          print('  ❌ Error with ${entry.key}: $e');
        }
      }
      
      print('🎉 Upload completed: $uploadedCount missionaries uploaded');
      return uploadedCount > 0;
      
    } catch (e) {
      print('❌ Upload failed: $e');
      return false;
    }
  }
  
  /// Direct upload function that returns a future
  static Future<UploadResult> _directUpload() async {
    try {
      print('🚀 Starting direct upload...');
      
      // Load missionary data from assets
      final jsonString = await rootBundle.loadString('assets/data/missionaries.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      print('📁 Loaded ${jsonData.length} missionaries');
      
      int uploadedCount = 0;
      int updatedCount = 0;
      List<String> errors = [];
      
      // Upload each missionary
      for (final entry in jsonData.entries) {
        try {
          final String key = entry.key;
          final Map<String, dynamic> data = entry.value as Map<String, dynamic>;
          
          // Convert to Firestore format
          final missionaryData = {
            'fullName': data['fullName'] ?? '',
            'heroImageUrl': data['heroImageUrl'] ?? '',
            'bio': data['bio'] ?? '',
            'fieldOfService': _arrayToString(data['fieldOfService']),
            'countryOfService': _arrayToString(data['countryOfService']),
            'century': _determineCentury(data['birthDate']),
            'birthDate': data['birthDate'],
            'deathDate': data['deathDate'],
            'placesOfWork': data['placesOfWork'] ?? [],
            'quotes': data['quotes'] ?? [],
            'legacy': data['legacy'] ?? '',
            'sourceKey': key,
            'lastUpdated': FieldValue.serverTimestamp(),
            'createdAt': FieldValue.serverTimestamp(),
          };
          
          // Upload to Firestore
          final docRef = _firestore.collection('missionaries').doc(key);
          final existingDoc = await docRef.get();
          
          if (existingDoc.exists) {
            await docRef.update(missionaryData);
            updatedCount++;
            print('  ✅ Updated: ${data['fullName']}');
          } else {
            await docRef.set(missionaryData);
            uploadedCount++;
            print('  ✅ Created: ${data['fullName']}');
          }
          
          // Small delay
          await Future.delayed(const Duration(milliseconds: 50));
          
        } catch (e) {
          print('  ❌ Error with ${entry.key}: $e');
          errors.add('${entry.key}: $e');
        }
      }
      
      print('🎉 Upload completed: Created=$uploadedCount, Updated=$updatedCount, Errors=${errors.length}');
      
      return UploadResult(
        success: errors.length == 0,
        message: 'Upload completed successfully!',
        uploadedCount: uploadedCount,
        updatedCount: updatedCount,
        errors: errors,
      );
      
    } catch (e) {
      print('❌ Direct upload failed: $e');
      return UploadResult(
        success: false,
        message: 'Upload failed: $e',
        uploadedCount: 0,
        updatedCount: 0,
        errors: [e.toString()],
      );
    }
  }
  
  /// Helper functions
  static String _arrayToString(dynamic value) {
    if (value is List) {
      return value.join(', ');
    }
    return value?.toString() ?? '';
  }
  
  static String _determineCentury(String? birthDate) {
    if (birthDate == null || birthDate.isEmpty) return 'Unknown';
    
    try {
      final year = int.parse(birthDate.substring(0, 4));
      final century = ((year - 1) ~/ 100) + 1;
      
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
}

/// Simple result class
class UploadResult {
  final bool success;
  final String message;
  final int uploadedCount;
  final int updatedCount;
  final List<String> errors;

  UploadResult({
    required this.success,
    required this.message,
    required this.uploadedCount,
    required this.updatedCount,
    required this.errors,
  });
}