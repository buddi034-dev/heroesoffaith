import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

/// File-based uploader with validation
class FileUploader {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// Show file selection dialog
  static void showFileUpload(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.file_upload, color: Colors.blue),
            SizedBox(width: 8),
            Text('Upload from File'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select a JSON file with missionary data from your device.'),
            SizedBox(height: 12),
            Text('Required JSON format:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('• fullName (required)'),
            Text('• heroImageUrl (optional)'),
            Text('• bio (optional)'),
            Text('• fieldOfService (optional)'),
            Text('• countryOfService (optional)'),
            Text('• birthDate, deathDate, quotes, etc.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _selectAndUploadFile(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Select File'),
          ),
        ],
      ),
    );
  }
  
  /// Select file and validate
  static Future<void> _selectAndUploadFile(BuildContext context) async {
    try {
      // Pick JSON file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileName = result.files.single.name;
        
        // Show loading
        if (context.mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (loadingContext) => AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text('Validating $fileName...'),
                ],
              ),
            ),
          );
        }
        
        // Validate file
        final validation = await _validateJsonFile(file);
        
        if (context.mounted) {
          Navigator.of(context).pop(); // Close loading
          
          if (validation.isValid) {
            // Show confirmation
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (confirmContext) => AlertDialog(
                title: const Text('✅ File Valid'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('File: $fileName'),
                    Text('Records: ${validation.recordCount}'),
                    Text('Valid: ${validation.validCount}'),
                    const SizedBox(height: 12),
                    const Text('Upload to Firestore?'),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(confirmContext).pop(false),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(confirmContext).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Upload'),
                  ),
                ],
              ),
            );
            
            if (confirmed == true) {
              await _uploadFromFile(context, file);
            }
          } else {
            // Show validation errors
            _showValidationError(context, validation, fileName);
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (errorContext) => AlertDialog(
            title: const Text('❌ File Selection Error'),
            content: Text('Error selecting file: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(errorContext).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }
  
  /// Validate JSON file structure
  static Future<FileValidationResult> _validateJsonFile(File file) async {
    try {
      final jsonString = await file.readAsString();
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      int validCount = 0;
      List<String> errors = [];
      List<String> warnings = [];
      
      for (final entry in jsonData.entries) {
        final key = entry.key;
        final data = entry.value;
        
        if (data is! Map<String, dynamic>) {
          errors.add('$key: Invalid data structure (must be object)');
          continue;
        }
        
        final record = data as Map<String, dynamic>;
        
        // Check required fields
        if (record['fullName'] == null || record['fullName'].toString().trim().isEmpty) {
          errors.add('$key: Missing or empty "fullName" field');
          continue;
        }
        
        // Check optional but important fields
        if (record['heroImageUrl'] == null || record['heroImageUrl'].toString().trim().isEmpty) {
          warnings.add('$key: Missing "heroImageUrl" - card image may not display');
        }
        
        if (record['bio'] == null || record['bio'].toString().trim().isEmpty) {
          warnings.add('$key: Missing "bio" field');
        }
        
        validCount++;
      }
      
      return FileValidationResult(
        isValid: errors.isEmpty,
        recordCount: jsonData.length,
        validCount: validCount,
        errors: errors,
        warnings: warnings,
      );
      
    } catch (e) {
      return FileValidationResult(
        isValid: false,
        recordCount: 0,
        validCount: 0,
        errors: ['Failed to parse JSON: $e'],
        warnings: [],
      );
    }
  }
  
  /// Show validation error dialog
  static void _showValidationError(BuildContext context, FileValidationResult validation, String fileName) {
    showDialog(
      context: context,
      builder: (errorContext) => AlertDialog(
        title: const Text('❌ Validation Failed'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('File: $fileName'),
              Text('Records: ${validation.recordCount}'),
              Text('Valid: ${validation.validCount}'),
              const SizedBox(height: 12),
              if (validation.errors.isNotEmpty) ...[
                const Text('❌ Errors:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                ...validation.errors.take(5).map((error) => Text('• $error', style: const TextStyle(fontSize: 12))),
                if (validation.errors.length > 5)
                  Text('... and ${validation.errors.length - 5} more errors'),
                const SizedBox(height: 8),
              ],
              if (validation.warnings.isNotEmpty) ...[
                const Text('⚠️ Warnings:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                ...validation.warnings.take(3).map((warning) => Text('• $warning', style: const TextStyle(fontSize: 12))),
                if (validation.warnings.length > 3)
                  Text('... and ${validation.warnings.length - 3} more warnings'),
                const SizedBox(height: 8),
              ],
              const Text('\n💡 Fix the errors in your JSON file and try again.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(errorContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  /// Upload from selected file
  static Future<void> _uploadFromFile(BuildContext context, File file) async {
    try {
      // Show loading
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (loadingContext) => const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Uploading missionaries to Firestore...'),
              ],
            ),
          ),
        );
      }
      
      // Upload data
      final success = await _uploadFileData(file);
      
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading
        
        // Show result
        showDialog(
          context: context,
          builder: (resultContext) => AlertDialog(
            title: Text(success ? '✅ Upload Success!' : '❌ Upload Failed'),
            content: Text(success 
              ? 'Missionaries uploaded successfully from file! Check Firebase Console.'
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
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading
        
        showDialog(
          context: context,
          builder: (errorContext) => AlertDialog(
            title: const Text('❌ Upload Error'),
            content: Text('Upload failed: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(errorContext).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }
  
  /// Upload data from file
  static Future<bool> _uploadFileData(File file) async {
    try {
      print('🚀 Starting upload from file...');
      
      final jsonString = await file.readAsString();
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      print('📁 Loaded ${jsonData.length} missionaries from file');
      
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

/// File validation result class
class FileValidationResult {
  final bool isValid;
  final int recordCount;
  final int validCount;
  final List<String> errors;
  final List<String> warnings;

  FileValidationResult({
    required this.isValid,
    required this.recordCount,
    required this.validCount,
    required this.errors,
    required this.warnings,
  });
}