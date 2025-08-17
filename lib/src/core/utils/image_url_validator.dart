import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

/// Tool to validate and fix Wikipedia Commons image URLs
class ImageUrlValidator {
  
  /// Show image URL validation dialog
  static void showValidation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.image_search, color: Colors.blue),
            SizedBox(width: 8),
            Text('Image URL Validator'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This will check all Wikipedia Commons image URLs in the missionary data and identify broken links.'),
            SizedBox(height: 12),
            Text('The tool will:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('• Check each heroImageUrl'),
            Text('• Test HTTP response codes'),
            Text('• Report broken URLs'),
            Text('• Suggest corrections if possible'),
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
              _performValidation(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Check URLs'),
          ),
        ],
      ),
    );
  }
  
  /// Perform URL validation
  static Future<void> _performValidation(BuildContext context) async {
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
                Text('Checking image URLs...'),
                SizedBox(height: 8),
                Text('This may take a moment', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
        );
      }
      
      // Validate URLs
      final result = await _validateImageUrls();
      
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading
        
        // Show results
        _showValidationResults(context, result);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading
        
        showDialog(
          context: context,
          builder: (errorContext) => AlertDialog(
            title: const Text('❌ Validation Error'),
            content: Text('Error checking URLs: $e'),
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
  
  /// Validate all image URLs
  static Future<ValidationResults> _validateImageUrls() async {
    try {
      print('🔍 Starting image URL validation...');
      
      final jsonString = await rootBundle.loadString('assets/data/missionaries.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      List<UrlResult> results = [];
      int total = jsonData.length;
      int checked = 0;
      
      for (final entry in jsonData.entries) {
        final key = entry.key;
        final data = entry.value as Map<String, dynamic>;
        final url = data['heroImageUrl'] as String?;
        
        if (url == null || url.isEmpty) {
          results.add(UrlResult(
            missionaryKey: key,
            missionaryName: data['fullName'] ?? key,
            url: '',
            status: 'MISSING',
            message: 'No heroImageUrl found',
          ));
        } else {
          print('  Checking: ${data['fullName']} - $url');
          final result = await _checkUrl(url);
          results.add(UrlResult(
            missionaryKey: key,
            missionaryName: data['fullName'] ?? key,
            url: url,
            status: result.status,
            message: result.message,
          ));
        }
        
        checked++;
        print('  Progress: $checked/$total');
        
        // Small delay to avoid rate limiting
        await Future.delayed(const Duration(milliseconds: 500));
      }
      
      final working = results.where((r) => r.status == 'OK').length;
      final broken = results.where((r) => r.status == 'BROKEN').length;
      final missing = results.where((r) => r.status == 'MISSING').length;
      
      print('🎉 Validation complete: $working working, $broken broken, $missing missing');
      
      return ValidationResults(
        total: total,
        working: working,
        broken: broken,
        missing: missing,
        results: results,
      );
      
    } catch (e) {
      print('❌ Validation failed: $e');
      throw Exception('Failed to validate URLs: $e');
    }
  }
  
  /// Check individual URL
  static Future<UrlCheckResult> _checkUrl(String url) async {
    try {
      final response = await http.head(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
      );
      
      if (response.statusCode == 200) {
        return UrlCheckResult(status: 'OK', message: 'Image accessible');
      } else {
        return UrlCheckResult(
          status: 'BROKEN', 
          message: 'HTTP ${response.statusCode}',
        );
      }
    } catch (e) {
      return UrlCheckResult(
        status: 'BROKEN', 
        message: 'Connection failed: ${e.toString().length > 50 ? e.toString().substring(0, 50) + "..." : e.toString()}',
      );
    }
  }
  
  /// Show validation results
  static void _showValidationResults(BuildContext context, ValidationResults results) {
    showDialog(
      context: context,
      builder: (resultContext) => AlertDialog(
        title: const Text('🔍 URL Validation Results'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Summary:', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('✅ Working: ${results.working}/${results.total}'),
                    Text('❌ Broken: ${results.broken}/${results.total}'),
                    Text('⚠️ Missing: ${results.missing}/${results.total}'),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Results list
              const Text('Details:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              
              Expanded(
                child: ListView.builder(
                  itemCount: results.results.length,
                  itemBuilder: (context, index) {
                    final result = results.results[index];
                    Color statusColor;
                    IconData statusIcon;
                    
                    switch (result.status) {
                      case 'OK':
                        statusColor = Colors.green;
                        statusIcon = Icons.check_circle;
                        break;
                      case 'BROKEN':
                        statusColor = Colors.red;
                        statusIcon = Icons.error;
                        break;
                      case 'MISSING':
                        statusColor = Colors.orange;
                        statusIcon = Icons.warning;
                        break;
                      default:
                        statusColor = Colors.grey;
                        statusIcon = Icons.help;
                    }
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        dense: true,
                        leading: Icon(statusIcon, color: statusColor, size: 20),
                        title: Text(
                          result.missionaryName,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (result.url.isNotEmpty)
                              Text(
                                result.url.length > 60 
                                  ? '${result.url.substring(0, 60)}...' 
                                  : result.url,
                                style: const TextStyle(fontSize: 11),
                              ),
                            Text(
                              result.message,
                              style: TextStyle(fontSize: 11, color: statusColor),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(resultContext).pop(),
            child: const Text('Close'),
          ),
          if (results.broken > 0)
            ElevatedButton(
              onPressed: () {
                Navigator.of(resultContext).pop();
                _showBrokenUrlsHelp(context, results);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Fix Broken URLs'),
            ),
        ],
      ),
    );
  }
  
  /// Show help for fixing broken URLs
  static void _showBrokenUrlsHelp(BuildContext context, ValidationResults results) {
    final brokenUrls = results.results.where((r) => r.status == 'BROKEN').toList();
    
    showDialog(
      context: context,
      builder: (helpContext) => AlertDialog(
        title: const Text('🔧 Fix Broken URLs'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'To fix broken Wikipedia Commons URLs:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text('1. Go to Wikipedia Commons (commons.wikimedia.org)'),
              const Text('2. Search for the missionary\'s name'),
              const Text('3. Find the correct image'),
              const Text('4. Copy the direct file URL'),
              const Text('5. Update your JSON file'),
              const SizedBox(height: 16),
              
              const Text('Broken URLs:', style: TextStyle(fontWeight: FontWeight.bold)),
              Expanded(
                child: ListView.builder(
                  itemCount: brokenUrls.length,
                  itemBuilder: (context, index) {
                    final result = brokenUrls[index];
                    return Card(
                      child: ListTile(
                        dense: true,
                        title: Text(result.missionaryName, style: const TextStyle(fontSize: 14)),
                        subtitle: Text(
                          result.url,
                          style: const TextStyle(fontSize: 11, color: Colors.red),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(helpContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

/// URL validation result classes
class ValidationResults {
  final int total;
  final int working;
  final int broken;
  final int missing;
  final List<UrlResult> results;
  
  ValidationResults({
    required this.total,
    required this.working,
    required this.broken,
    required this.missing,
    required this.results,
  });
}

class UrlResult {
  final String missionaryKey;
  final String missionaryName;
  final String url;
  final String status;
  final String message;
  
  UrlResult({
    required this.missionaryKey,
    required this.missionaryName,
    required this.url,
    required this.status,
    required this.message,
  });
}

class UrlCheckResult {
  final String status;
  final String message;
  
  UrlCheckResult({
    required this.status,
    required this.message,
  });
}