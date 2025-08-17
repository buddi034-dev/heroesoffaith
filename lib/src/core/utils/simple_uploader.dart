import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Simple uploader that avoids complex dependencies
/// This is the minimal version that should work without import issues
class SimpleUploader {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// Upload JSON data from assets
  static Future<SimpleUploadResult> uploadFromAssets() async {
    try {
      print('🚀 Starting upload from assets...');
      
      // Read JSON from assets
      print('📁 Loading assets/data/missionaries.json...');
      final jsonString = await rootBundle.loadString('assets/data/missionaries.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      print('✅ Loaded ${jsonData.length} missionaries from assets');
      
      int uploadedCount = 0;
      int updatedCount = 0;
      List<String> errors = [];

      // Process each missionary
      for (final entry in jsonData.entries) {
        try {
          final String key = entry.key;
          final Map<String, dynamic> data = entry.value as Map<String, dynamic>;
          
          print('👤 Processing: ${data['fullName'] ?? key}');
          
          // Convert to Firestore format
          final missionaryData = _convertToFirestore(key, data);
          
          // Check if document exists
          final docRef = _firestore.collection('missionaries').doc(key);
          final existingDoc = await docRef.get();
          
          if (existingDoc.exists) {
            await docRef.update(missionaryData);
            updatedCount++;
            print('  ✅ Updated existing missionary');
          } else {
            await docRef.set(missionaryData);
            uploadedCount++;
            print('  ✅ Created new missionary');
          }

          // Small delay to avoid rate limiting
          await Future.delayed(const Duration(milliseconds: 100));

        } catch (e) {
          print('  ❌ Error processing ${entry.key}: $e');
          errors.add('Failed to process ${entry.key}: $e');
        }
      }

      print('🎉 Upload completed: Created=$uploadedCount, Updated=$updatedCount, Errors=${errors.length}');

      return SimpleUploadResult(
        success: errors.length < jsonData.length,
        message: 'Upload completed. Created: $uploadedCount, Updated: $updatedCount, Errors: ${errors.length}',
        uploadedCount: uploadedCount,
        updatedCount: updatedCount,
        errors: errors,
      );

    } catch (e) {
      print('❌ Upload failed with error: $e');
      return SimpleUploadResult(
        success: false,
        message: 'Upload failed: $e',
        uploadedCount: 0,
      );
    }
  }

  /// Convert JSON data to Firestore format
  static Map<String, dynamic> _convertToFirestore(String key, Map<String, dynamic> jsonData) {
    // Helper function to convert arrays to strings
    String arrayToString(dynamic value) {
      if (value is List) {
        return value.join(', ');
      }
      return value?.toString() ?? '';
    }

    // Helper function to determine century from birth date
    String determineCentury(String? birthDate) {
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

    return {
      // Basic fields for compatibility with existing model
      'fullName': jsonData['fullName'] ?? '',
      'heroImageUrl': jsonData['heroImageUrl'] ?? '',
      'bio': jsonData['bio'] ?? '',
      'fieldOfService': arrayToString(jsonData['fieldOfService']),
      'countryOfService': arrayToString(jsonData['countryOfService']),
      'century': determineCentury(jsonData['birthDate']),
      
      // Additional rich data
      'birthDate': jsonData['birthDate'],
      'deathDate': jsonData['deathDate'],
      'placesOfWork': jsonData['placesOfWork'] ?? [],
      'quotes': jsonData['quotes'] ?? [],
      'legacy': jsonData['legacy'] ?? '',
      
      // Metadata
      'sourceKey': key,
      'lastUpdated': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  /// Simple validation check from assets
  static Future<SimpleValidationResult> validateFromAssets() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/missionaries.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      int validCount = 0;
      List<String> errors = [];

      for (final entry in jsonData.entries) {
        final data = entry.value;
        if (data is Map<String, dynamic>) {
          if (data['fullName'] != null && data['fullName'].toString().isNotEmpty) {
            validCount++;
          } else {
            errors.add('Missing fullName for ${entry.key}');
          }
        } else {
          errors.add('Invalid data structure for ${entry.key}');
        }
      }

      return SimpleValidationResult(
        isValid: errors.isEmpty,
        message: errors.isEmpty 
            ? 'Validation passed: $validCount valid records'
            : 'Validation failed: ${errors.length} errors found',
        recordCount: jsonData.length,
        validCount: validCount,
        errors: errors,
      );

    } catch (e) {
      return SimpleValidationResult(
        isValid: false,
        message: 'Failed to validate: $e',
        recordCount: 0,
      );
    }
  }

  /// Show simple upload dialog
  static void showUploadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.upload, color: Colors.blue),
            SizedBox(width: 8),
            Text('Upload Missionary Data'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('This will upload 28 missionaries to Firestore database.'),
              SizedBox(height: 12),
              Text('✅ William Carey, Mother Teresa, Amy Carmichael'),
              Text('✅ Hudson Taylor, David Livingstone, and 23 more'),
              SizedBox(height: 12),
              Text('The data is built into the app, so no file selection needed!',
                style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _performUpload(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Upload Now'),
          ),
        ],
      ),
    );
  }

  /// Perform the upload process with proper error handling
  static Future<void> _performUpload(BuildContext context) async {
    // Store navigator for safe access
    final navigator = Navigator.of(context);
    navigator.pop(); // Close the dialog
    
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Validating missionary data...'),
          ],
        ),
      ),
    );

    try {
      // Validate first
      final validation = await validateFromAssets();
      if (context.mounted) navigator.pop(); // Close loading safely
      
      if (!validation.isValid) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('❌ Validation Failed'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(validation.message),
                  if (validation.errors.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Text('Errors:', style: TextStyle(fontWeight: FontWeight.bold)),
                    ...validation.errors.take(3).map((error) => Text('• $error')),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }

      // Show validation results and confirm
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('✅ Ready to Upload'),
          content: Text('${validation.message}\n\nThis will add/update missionaries in your Firestore database. Proceed?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Yes, Upload'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        // Show upload loading
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Colors.green),
                SizedBox(height: 16),
                Text('Uploading missionaries to Firestore...'),
                SizedBox(height: 8),
                Text('Please wait, this may take a moment.', 
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        );

        // Upload data
        final result = await uploadFromAssets();
        if (context.mounted) navigator.pop(); // Close loading safely

        // Show results
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(result.success ? Icons.check_circle : Icons.warning, 
                  color: result.success ? Colors.green : Colors.orange),
                const SizedBox(width: 8),
                Text(result.success ? '🎉 Upload Successful!' : '⚠️ Upload Issues'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(result.message),
                  if (result.uploadedCount > 0)
                    Text('✅ New missionaries: ${result.uploadedCount}'),
                  if (result.updatedCount > 0)
                    Text('🔄 Updated missionaries: ${result.updatedCount}'),
                  if (result.errors.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text('❌ Errors (${result.errors.length}):'),
                    ...result.errors.take(3).map((error) => Text('• $error', 
                      style: const TextStyle(fontSize: 12))),
                  ],
                  if (result.success) ...[
                    const SizedBox(height: 12),
                    const Text('🎯 Next Steps:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const Text('• Go to Firebase Console to see your data'),
                    const Text('• Check "Missionary Directory" in the app'),
                    const Text('• All 28 missionaries are now available!'),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Great!'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) navigator.pop(); // Close any loading dialog safely
      print('Upload error: $e'); // Debug log
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('❌ Upload Error'),
          content: Text('An error occurred: $e\n\nPlease check your Firebase configuration and internet connection.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}

/// Simple result classes
class SimpleUploadResult {
  final bool success;
  final String message;
  final int uploadedCount;
  final int updatedCount;
  final List<String> errors;

  SimpleUploadResult({
    required this.success,
    required this.message,
    required this.uploadedCount,
    this.updatedCount = 0,
    this.errors = const [],
  });
}

class SimpleValidationResult {
  final bool isValid;
  final String message;
  final int recordCount;
  final int validCount;
  final List<String> errors;

  SimpleValidationResult({
    required this.isValid,
    required this.message,
    required this.recordCount,
    this.validCount = 0,
    this.errors = const [],
  });
}