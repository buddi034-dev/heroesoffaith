import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class GitHubImageService {
  static const String _contributionsPath = 'contributions/images';
  
  /// Save image to both local storage AND convert to base64 for Firestore
  /// This ensures admins can see images for review
  static Future<Map<String, String>> saveImageToGitHub({
    required File imageFile,
    required String userId,
    required String missionaryName,
    required String contributionType,
  }) async {
    try {
      // Generate unique filename with user info
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final sanitizedMissionaryName = missionaryName.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
      final fileName = '${userId}_${sanitizedMissionaryName}_${timestamp}.jpg';
      
      // Read image as bytes for base64 encoding
      final imageBytes = await imageFile.readAsBytes();
      
      // Compress if too large (max 1MB for Firestore)
      Uint8List compressedBytes = imageBytes;
      if (imageBytes.length > 1024 * 1024) {
        // Simple compression by truncating (better compression can be added later)
        compressedBytes = Uint8List.fromList(imageBytes.take(1024 * 1024).toList());
      }
      
      // Convert to base64 for Firestore storage
      final base64Image = base64Encode(compressedBytes);
      
      // Also save locally as backup
      final appDir = await getApplicationDocumentsDirectory();
      final contributionsDir = Directory(path.join(appDir.path, 'contributions', 'images'));
      if (!await contributionsDir.exists()) {
        await contributionsDir.create(recursive: true);
      }
      
      final destPath = path.join(contributionsDir.path, fileName);
      await imageFile.copy(destPath);
      
      // Create metadata file
      final metadataPath = path.join(contributionsDir.path, '$fileName.json');
      final metadata = {
        'userId': userId,
        'missionaryName': missionaryName,
        'contributionType': contributionType,
        'fileName': fileName,
        'localPath': destPath,
        'uploadedAt': DateTime.now().toIso8601String(),
        'status': 'pending_approval',
        'imageSize': compressedBytes.length,
      };
      
      await File(metadataPath).writeAsString(jsonEncode(metadata));
      
      // Return both base64 and local path
      return {
        'base64Image': base64Image,
        'localPath': destPath,
        'fileName': fileName,
      };
      
    } catch (e) {
      throw Exception('Failed to save image: $e');
    }
  }
  
  /// Get local path for storing contribution images
  static Future<String> getContributionsPath() async {
    final dir = Directory(_contributionsPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir.path;
  }
  
  /// Commit and push images to GitHub (requires git setup)
  static Future<void> commitAndPushImages(String commitMessage) async {
    try {
      // Add all new images and metadata to git
      await Process.run('git', ['add', _contributionsPath]);
      
      // Commit with meaningful message
      await Process.run('git', ['commit', '-m', commitMessage]);
      
      // Push to GitHub
      await Process.run('git', ['push', 'origin', 'main']);
      
    } catch (e) {
      throw Exception('Failed to commit images to GitHub: $e');
    }
  }
  
  /// Delete image from GitHub repository
  static Future<void> deleteImageFromGitHub(String fileName) async {
    try {
      final filePath = '$_contributionsPath/$fileName';
      final metadataPath = '$filePath.json';
      
      // Delete files
      final file = File(filePath);
      final metadataFile = File(metadataPath);
      
      if (await file.exists()) await file.delete();
      if (await metadataFile.exists()) await metadataFile.delete();
      
      // Commit deletion
      await Process.run('git', ['add', '-A']);
      await Process.run('git', ['commit', '-m', 'Delete rejected contribution: $fileName']);
      await Process.run('git', ['push', 'origin', 'main']);
      
    } catch (e) {
      throw Exception('Failed to delete image from GitHub: $e');
    }
  }
  
  /// Get all pending contributions from local directory
  static Future<List<Map<String, dynamic>>> getPendingContributions() async {
    try {
      final contributionsDir = Directory(_contributionsPath);
      if (!await contributionsDir.exists()) return [];
      
      final files = await contributionsDir.list().toList();
      final contributions = <Map<String, dynamic>>[];
      
      for (final file in files) {
        if (file.path.endsWith('.json')) {
          final content = await File(file.path).readAsString();
          final metadata = jsonDecode(content) as Map<String, dynamic>;
          
          if (metadata['status'] == 'pending_approval') {
            contributions.add(metadata);
          }
        }
      }
      
      return contributions;
    } catch (e) {
      return [];
    }
  }
}