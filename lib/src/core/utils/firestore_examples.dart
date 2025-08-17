import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/admin/presentation/screens/missionary_edit_screen.dart';
import '../services/firestore_service.dart';
import '../../../models/missionary.dart';

/// This file contains practical examples of Firestore database operations
/// Use these patterns in your app screens and services
class FirestoreExamples {
  static final FirestoreService _service = FirestoreService();

  /// Example 1: Basic CRUD Operations
  static Future<void> basicCrudExamples() async {
    try {
      // CREATE - Add a new missionary
      final newMissionary = Missionary(
        id: '',
        fullName: 'William Carey',
        heroImageUrl: 'https://example.com/william-carey.jpg',
        bio: 'Known as the father of modern missions',
        fieldOfService: 'Translation & Evangelism',
        countryOfService: 'India',
        century: '18th Century',
      );

      final missionaryId = await _service.createMissionary(newMissionary);
      print('✅ Created missionary with ID: $missionaryId');

      // READ - Get the missionary back
      final retrievedMissionary = await _service.getMissionaryById(missionaryId);
      if (retrievedMissionary != null) {
        print('✅ Retrieved: ${retrievedMissionary.fullName}');
      }

      // UPDATE - Update the missionary
      final updatedMissionary = retrievedMissionary!.copyWith(
        bio: 'William Carey was an English Christian missionary, known as the "father of modern missions".',
      );
      await _service.updateMissionary(missionaryId, updatedMissionary);
      print('✅ Updated missionary biography');

      // UPDATE SPECIFIC FIELDS - More efficient for single field updates
      await _service.updateMissionaryFields(missionaryId, {
        'fieldOfService': 'Bible Translation, Education, Evangelism',
      });
      print('✅ Updated specific field');

      // DELETE - Remove the missionary (uncomment to test)
      // await _service.deleteMissionary(missionaryId);
      // print('✅ Deleted missionary');

    } catch (e) {
      print('❌ Error in CRUD operations: $e');
    }
  }

  /// Example 2: Batch Operations
  static Future<void> batchOperationExamples() async {
    try {
      // Batch create multiple missionaries
      final missionaries = [
        Missionary(
          id: '',
          fullName: 'Hudson Taylor',
          heroImageUrl: 'https://example.com/hudson-taylor.jpg',
          bio: 'British Protestant Christian missionary to China',
          fieldOfService: 'Evangelism',
          countryOfService: 'China',
          century: '19th Century',
        ),
        Missionary(
          id: '',
          fullName: 'Amy Carmichael',
          heroImageUrl: 'https://example.com/amy-carmichael.jpg',
          bio: 'Irish Christian missionary in India',
          fieldOfService: 'Child Rescue',
          countryOfService: 'India',
          century: '20th Century',
        ),
      ];

      final newIds = await _service.batchCreateMissionaries(missionaries);
      print('✅ Batch created ${newIds.length} missionaries');

      // Batch update multiple missionaries
      final updates = <String, Missionary>{};
      for (int i = 0; i < newIds.length; i++) {
        updates[newIds[i]] = missionaries[i].copyWith(
          id: newIds[i],
          bio: '${missionaries[i].bio} - Updated via batch operation',
        );
      }
      await _service.batchUpdateMissionaries(updates);
      print('✅ Batch updated missionaries');

    } catch (e) {
      print('❌ Error in batch operations: $e');
    }
  }

  /// Example 3: Streaming Data (Real-time updates)
  static void streamingExamples() {
    // Listen to all missionaries (real-time)
    final missionariesStream = _service.getMissionariesStream(limit: 10);
    missionariesStream.listen(
      (missionaries) {
        print('📡 Received ${missionaries.length} missionaries from stream');
        for (final missionary in missionaries) {
          print('  - ${missionary.fullName} (${missionary.countryOfService})');
        }
      },
      onError: (error) {
        print('❌ Stream error: $error');
      },
    );

    // Listen to a specific missionary
    const missionaryId = 'some-missionary-id';
    final singleMissionaryStream = _service.getMissionaryStream(missionaryId);
    singleMissionaryStream.listen(
      (missionary) {
        if (missionary != null) {
          print('📡 Missionary updated: ${missionary.fullName}');
        } else {
          print('📡 Missionary not found or deleted');
        }
      },
    );
  }

  /// Example 4: Filtering and Searching
  static Future<void> filteringExamples() async {
    try {
      // Get all missionaries from India
      final indianMissionariesStream = _service.getMissionariesByCountry('India');
      await for (final missionaries in indianMissionariesStream.take(1)) {
        print('✅ Found ${missionaries.length} missionaries in India');
      }

      // Get missionaries from 19th century
      final c19MissionariesStream = _service.getMissionariesByCentury('19th Century');
      await for (final missionaries in c19MissionariesStream.take(1)) {
        print('✅ Found ${missionaries.length} missionaries from 19th century');
      }

      // Search missionaries by name/content
      final searchStream = _service.searchMissionaries('william');
      await for (final results in searchStream.take(1)) {
        print('✅ Search results: ${results.length} missionaries found');
      }

    } catch (e) {
      print('❌ Error in filtering: $e');
    }
  }

  /// Example 5: Using Raw Firestore (for complex queries)
  static Future<void> rawFirestoreExamples() async {
    try {
      final firestore = FirebaseFirestore.instance;

      // Complex query: Missionaries from India OR China in 19th century
      final query = firestore
          .collection('missionaries')
          .where('century', isEqualTo: '19th Century')
          .where('countryOfService', whereIn: ['India', 'China'])
          .orderBy('fullName')
          .limit(5);

      final snapshot = await query.get();
      print('✅ Complex query returned ${snapshot.docs.length} results');

      // Using transactions for atomic updates
      await firestore.runTransaction((transaction) async {
        // Read operation
        const docId = 'some-missionary-id';
        final docRef = firestore.collection('missionaries').doc(docId);
        final doc = await transaction.get(docRef);

        if (doc.exists) {
          // Update operation within transaction
          transaction.update(docRef, {
            'bio': 'Updated biography in transaction',
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        }
      });
      print('✅ Transaction completed');

      // Aggregate queries (count)
      final countQuery = firestore.collection('missionaries');
      final countSnapshot = await countQuery.count().get();
      print('✅ Total missionaries count: ${countSnapshot.count}');

    } catch (e) {
      print('❌ Error in raw Firestore operations: $e');
    }
  }

  /// Example 6: Error Handling Patterns
  static Future<void> errorHandlingExamples() async {
    try {
      // Attempt to get non-existent missionary
      const fakeId = 'non-existent-id';
      final missionary = await _service.getMissionaryById(fakeId);
      if (missionary == null) {
        print('⚠️ Missionary not found - handled gracefully');
      }

      // Check if missionary exists before operations
      final exists = await _service.missionaryExists(fakeId);
      if (!exists) {
        print('⚠️ Missionary does not exist - skipping operation');
        return;
      }

      // Use try-catch for operations that might fail
      await _service.updateMissionaryFields(fakeId, {'bio': 'New bio'});

    } on FirebaseException catch (e) {
      // Handle Firebase-specific errors
      switch (e.code) {
        case 'permission-denied':
          print('❌ Permission denied: ${e.message}');
          break;
        case 'not-found':
          print('❌ Document not found: ${e.message}');
          break;
        default:
          print('❌ Firebase error: ${e.code} - ${e.message}');
      }
    } catch (e) {
      // Handle general errors
      print('❌ General error: $e');
    }
  }

  /// Example 7: Performance Optimization
  static Future<void> performanceExamples() async {
    try {
      // Limit queries for better performance
      final limitedMissionaries = await _service.getMissionaries(limit: 20);
      print('✅ Fetched ${limitedMissionaries.length} missionaries (limited)');

      // Use pagination for large datasets
      Query query = FirebaseFirestore.instance
          .collection('missionaries')
          .orderBy('fullName')
          .limit(10);

      final firstPage = await query.get();
      print('✅ First page: ${firstPage.docs.length} items');

      if (firstPage.docs.isNotEmpty) {
        // Get next page using the last document as cursor
        final nextPage = await query
            .startAfterDocument(firstPage.docs.last)
            .get();
        print('✅ Next page: ${nextPage.docs.length} items');
      }

      // Use streams for real-time data instead of polling
      final streamController = _service.getMissionariesStream(limit: 10);
      final subscription = streamController.listen(
        (missionaries) => print('📡 Real-time update: ${missionaries.length} items'),
      );

      // Clean up subscription when done
      await Future.delayed(const Duration(seconds: 1));
      await subscription.cancel();

    } catch (e) {
      print('❌ Performance example error: $e');
    }
  }
}

/// Utility class for common Firestore operations in UI components
class FirestoreUIHelpers {
  static final FirestoreService _service = FirestoreService();

  /// Show a loading dialog while performing Firestore operations
  static Future<T?> withLoadingDialog<T>(
    BuildContext context,
    Future<T> operation, {
    String? loadingText,
  }) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(loadingText ?? 'Processing...'),
          ],
        ),
      ),
    );

    try {
      final result = await operation;
      Navigator.of(context).pop(); // Close loading dialog
      return result;
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      
      // Show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Operation failed: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      
      return null;
    }
  }

  /// Helper for showing success/error snackbars
  static void showResultSnackBar(
    BuildContext context,
    Future<void> operation,
    String successMessage,
    String errorMessage,
  ) {
    operation.then(
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: Colors.green,
          ),
        );
      },
      onError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$errorMessage: $error'),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }

  /// Helper for confirmation dialogs before destructive operations
  static Future<bool> showConfirmationDialog(
    BuildContext context,
    String title,
    String content,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}