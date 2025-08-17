import 'dart:io';
import 'package:flutter/material.dart';
import '../services/json_data_uploader.dart';

/// Quick example of how to integrate JSON upload into your app
/// This shows the simplest way to upload your JSON data
class QuickUploadExample {
  
  /// Simple upload function that can be called from anywhere in your app
  static Future<void> uploadMissionaryData(BuildContext context) async {
    const String jsonFilePath = r'C:\Users\HP\AndroidStudioProjects\ChristCommander\herosoffaith\firestoreData.json';
    
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Uploading missionary data...'),
          ],
        ),
      ),
    );

    try {
      final uploader = JsonDataUploader();
      
      // Upload the data
      final result = await uploader.uploadFromJsonFile(jsonFilePath);
      
      // Close loading dialog
      Navigator.of(context).pop();
      
      // Show result
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(result.success ? 'Upload Successful' : 'Upload Completed with Errors'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(result.message),
              if (result.uploadedCount > 0)
                Text('New missionaries created: ${result.uploadedCount}'),
              if (result.updatedCount > 0)
                Text('Missionaries updated: ${result.updatedCount}'),
              if (result.errors.isNotEmpty)
                Text('Errors encountered: ${result.errors.length}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();
      
      // Show error
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Upload Failed'),
          content: Text('Error: $e'),
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

  /// Validate data without uploading
  static Future<void> validateMissionaryData(BuildContext context) async {
    const String jsonFilePath = r'C:\Users\HP\AndroidStudioProjects\ChristCommander\herosoffaith\firestoreData.json';
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Validating data...'),
          ],
        ),
      ),
    );

    try {
      final uploader = JsonDataUploader();
      
      // Read and validate
      final file = await File(jsonFilePath).readAsString();
      final result = uploader.validateJsonStructure(file);
      
      Navigator.of(context).pop();
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(result.isValid ? 'Validation Passed' : 'Validation Failed'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total records: ${result.totalRecords}'),
              Text('Valid records: ${result.validRecords}'),
              if (result.errors.isNotEmpty)
                Text('Errors: ${result.errors.length}'),
              if (result.warnings.isNotEmpty)
                Text('Warnings: ${result.warnings.length}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      
    } catch (e) {
      Navigator.of(context).pop();
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Validation Failed'),
          content: Text('Error: $e'),
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

/// Example widget showing how to add upload buttons to any screen
class UploadActionsWidget extends StatelessWidget {
  const UploadActionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () => QuickUploadExample.validateMissionaryData(context),
          icon: const Icon(Icons.check_circle),
          label: const Text('Validate JSON Data'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () => QuickUploadExample.uploadMissionaryData(context),
          icon: const Icon(Icons.upload),
          label: const Text('Upload to Firestore'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF667eea),
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}

/// Example of integrating into an existing screen
/// Add this to any admin screen or settings page
class AdminScreenWithUpload extends StatelessWidget {
  const AdminScreenWithUpload({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Functions'),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data Management',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text('Upload missionary data from JSON file to Firestore:'),
            SizedBox(height: 12),
            UploadActionsWidget(),
          ],
        ),
      ),
    );
  }
}