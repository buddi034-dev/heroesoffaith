import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Simple Firebase connection test
class FirebaseTest {
  
  /// Test Firestore connection
  static Future<bool> testFirestoreConnection() async {
    try {
      print('🔥 Testing Firestore connection...');
      
      // Try to write a test document
      final testDoc = FirebaseFirestore.instance.collection('test').doc('connection_test');
      await testDoc.set({
        'message': 'Connection test',
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      print('✅ Write test successful');
      
      // Try to read the document back
      final doc = await testDoc.get();
      if (doc.exists) {
        print('✅ Read test successful: ${doc.data()}');
      } else {
        print('⚠️ Document not found after write');
      }
      
      // Clean up test document
      await testDoc.delete();
      print('✅ Cleanup successful');
      
      return true;
    } catch (e) {
      print('❌ Firestore test failed: $e');
      return false;
    }
  }
  
  /// Test and show results in UI
  static void showFirebaseTest(BuildContext context) {
    // Store navigator for safe access
    final navigator = Navigator.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🔥 Firebase Connection Test'),
        content: const Text('Testing Firestore connection...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    
    // Run test
    testFirestoreConnection().then((success) {
      if (context.mounted) {
        navigator.pop(); // Close loading dialog
        
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(success ? '✅ Firebase Working!' : '❌ Firebase Issue'),
            content: Text(success 
              ? 'Firestore connection is working properly. You can upload data now.'
              : 'There\'s an issue with Firestore connection. Check your Firebase configuration.'
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }).catchError((error) {
      if (context.mounted) {
        navigator.pop(); // Close loading dialog
        
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('❌ Test Error'),
            content: Text('Firebase test failed: $error'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    });
  }
}