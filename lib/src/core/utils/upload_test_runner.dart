import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import '../services/json_data_uploader.dart';

/// Test runner for JSON data upload
/// Run this as a standalone script to test the upload process
class UploadTestRunner {
  static const String jsonFilePath = r'C:\Users\HP\AndroidStudioProjects\ChristCommander\herosoffaith\firestoreData.json';

  static Future<void> runUploadTest() async {
    print('🚀 Starting Firestore JSON Upload Test');
    print('=' * 50);
    
    try {
      // Initialize Firebase
      print('📱 Initializing Firebase...');
      await Firebase.initializeApp();
      print('✅ Firebase initialized successfully');

      final uploader = JsonDataUploader();

      // Step 1: Read JSON file
      print('\n📁 Reading JSON file...');
      final file = File(jsonFilePath);
      if (!await file.exists()) {
        throw Exception('JSON file not found at: $jsonFilePath');
      }
      
      final jsonContent = await file.readAsString();
      print('✅ JSON file read successfully (${jsonContent.length} characters)');

      // Step 2: Validate JSON structure
      print('\n🔍 Validating JSON structure...');
      final validationResult = uploader.validateJsonStructure(jsonContent);
      
      print('Validation Results:');
      print('  - Valid: ${validationResult.isValid}');
      print('  - Total Records: ${validationResult.totalRecords}');
      print('  - Valid Records: ${validationResult.validRecords}');
      print('  - Errors: ${validationResult.errors.length}');
      print('  - Warnings: ${validationResult.warnings.length}');

      if (validationResult.errors.isNotEmpty) {
        print('\nErrors found:');
        for (int i = 0; i < validationResult.errors.length && i < 5; i++) {
          print('  ${i + 1}. ${validationResult.errors[i]}');
        }
        if (validationResult.errors.length > 5) {
          print('  ... and ${validationResult.errors.length - 5} more errors');
        }
      }

      if (validationResult.warnings.isNotEmpty) {
        print('\nWarnings:');
        for (int i = 0; i < validationResult.warnings.length && i < 3; i++) {
          print('  ${i + 1}. ${validationResult.warnings[i]}');
        }
        if (validationResult.warnings.length > 3) {
          print('  ... and ${validationResult.warnings.length - 3} more warnings');
        }
      }

      if (!validationResult.isValid) {
        print('\n❌ Validation failed. Please fix errors before uploading.');
        return;
      }

      // Step 3: Create backup (optional)
      print('\n💾 Creating backup of existing data...');
      try {
        final backupContent = await uploader.backupExistingData();
        
        // Save backup to file
        final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
        final backupFile = File('missionaries_backup_$timestamp.json');
        await backupFile.writeAsString(backupContent);
        print('✅ Backup created: ${backupFile.path}');
      } catch (e) {
        print('⚠️  Backup failed (this is OK if collection is empty): $e');
      }

      // Step 4: Confirm upload
      print('\n❓ Do you want to proceed with uploading ${validationResult.validRecords} missionaries? (y/n)');
      final confirmation = stdin.readLineSync()?.toLowerCase();
      
      if (confirmation != 'y' && confirmation != 'yes') {
        print('❌ Upload cancelled by user.');
        return;
      }

      // Step 5: Upload data
      print('\n⬆️  Starting upload process...');
      final uploadResult = await uploader.batchUploadFromJsonString(jsonContent, batchSize: 5);
      
      print('\nUpload Results:');
      print('  - Success: ${uploadResult.success}');
      print('  - Created: ${uploadResult.uploadedCount}');
      print('  - Updated: ${uploadResult.updatedCount}');
      print('  - Errors: ${uploadResult.errors.length}');
      
      if (uploadResult.errors.isNotEmpty) {
        print('\nUpload errors:');
        for (int i = 0; i < uploadResult.errors.length && i < 5; i++) {
          print('  ${i + 1}. ${uploadResult.errors[i]}');
        }
        if (uploadResult.errors.length > 5) {
          print('  ... and ${uploadResult.errors.length - 5} more errors');
        }
      }

      if (uploadResult.success) {
        print('\n🎉 Upload completed successfully!');
        print('✅ Your missionaries are now available in Firestore');
      } else {
        print('\n⚠️  Upload completed with some errors. Check the details above.');
      }

    } catch (e) {
      print('❌ Test failed: $e');
      print('\nStackTrace:');
      print(e.toString());
    }

    print('\n' + '=' * 50);
    print('🏁 Upload test completed');
  }

  /// Simple validation test without uploading
  static Future<void> runValidationOnly() async {
    print('🔍 Running validation-only test');
    print('=' * 30);
    
    try {
      final uploader = JsonDataUploader();
      
      // Read JSON file
      final file = File(jsonFilePath);
      if (!await file.exists()) {
        throw Exception('JSON file not found at: $jsonFilePath');
      }
      
      final jsonContent = await file.readAsString();
      
      // Validate
      final result = uploader.validateJsonStructure(jsonContent);
      
      print('Validation Summary:');
      print('  File: $jsonFilePath');
      print('  Size: ${jsonContent.length} characters');
      print('  Valid: ${result.isValid}');
      print('  Records: ${result.validRecords}/${result.totalRecords}');
      print('  Errors: ${result.errors.length}');
      print('  Warnings: ${result.warnings.length}');
      
      if (result.isValid) {
        print('\n✅ Your JSON file is ready for upload!');
      } else {
        print('\n❌ Please fix validation errors before uploading');
      }
      
    } catch (e) {
      print('❌ Validation test failed: $e');
    }
  }

  /// Test individual conversion
  static void testDataConversion() {
    print('🧪 Testing data conversion');
    print('=' * 30);
    
    // Sample JSON data
    const sampleJson = '''
    {
      "testMissionary": {
        "fullName": "Test Missionary",
        "bio": "A test missionary for validation",
        "countryOfService": ["India", "China"],
        "fieldOfService": ["Evangelism", "Education"],
        "heroImageUrl": "https://example.com/test.jpg",
        "birthDate": "1800-01-01",
        "deathDate": "1900-01-01",
        "placesOfWork": ["Delhi", "Mumbai"],
        "quotes": ["Test quote"],
        "legacy": "Test legacy"
      }
    }
    ''';
    
    try {
      final uploader = JsonDataUploader();
      final result = uploader.validateJsonStructure(sampleJson);
      
      print('Sample conversion test:');
      print('  Valid: ${result.isValid}');
      print('  Records: ${result.totalRecords}');
      print('  Errors: ${result.errors}');
      print('  Warnings: ${result.warnings}');
      
      if (result.isValid) {
        print('✅ Data conversion working correctly');
      } else {
        print('❌ Data conversion has issues');
      }
      
    } catch (e) {
      print('❌ Conversion test failed: $e');
    }
  }
}

/// Main function to run tests
/// Uncomment the test you want to run
void main() async {
  print('🧪 Firestore JSON Upload Tests');
  print('Choose a test to run:');
  print('1. Full upload test (includes Firebase initialization)');
  print('2. Validation only test');
  print('3. Data conversion test');
  
  // Uncomment ONE of the following lines to run a specific test:
  
  // await UploadTestRunner.runUploadTest();        // Full test with upload
  await UploadTestRunner.runValidationOnly();       // Validation only
  // UploadTestRunner.testDataConversion();         // Conversion test only
}