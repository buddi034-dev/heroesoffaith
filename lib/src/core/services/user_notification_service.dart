import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserNotificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// Create notification for user when their contribution status changes
  static Future<void> notifyUserOfStatusChange({
    required String userId,
    required String contributionId,
    required String contributionType,
    required String missionaryName,
    required String newStatus,
    String? rejectionReason,
  }) async {
    try {
      String message;
      String title;
      
      switch (newStatus) {
        case 'approved':
          title = '✨ Contribution Blessed!';
          message = 'Your $contributionType for $missionaryName has been blessed and will be displayed to inspire others in their faith journey.';
          break;
        case 'rejected':
          title = '💭 Contribution Under Review';
          message = 'Your $contributionType for $missionaryName needs some adjustments. ${rejectionReason ?? "Please consider resubmitting with more details or contact our curators for guidance."}';
          break;
        default:
          return; // Don't notify for pending status
      }
      
      // Create user notification record
      await _firestore.collection('user_notifications').add({
        'userId': userId,
        'contributionId': contributionId,
        'type': 'contribution_status_change',
        'title': title,
        'message': message,
        'contributionType': contributionType,
        'missionaryName': missionaryName,
        'status': newStatus,
        'rejectionReason': rejectionReason,
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      });
      
      debugPrint('✅ User notification created for $newStatus contribution');
    } catch (e) {
      debugPrint('❌ Failed to create user notification: $e');
    }
  }
  
  /// Get user notifications stream
  static Stream<QuerySnapshot> getUserNotifications(String userId) {
    return _firestore
        .collection('user_notifications')
        .where('userId', isEqualTo: userId)
        .where('read', isEqualTo: false)
        .orderBy('timestamp', descending: true)
        .limit(10)
        .snapshots();
  }
  
  /// Mark notification as read
  static Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('user_notifications')
          .doc(notificationId)
          .update({'read': true});
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }
  
  /// Get count of unread user notifications
  static Stream<int> getUnreadNotificationCount(String userId) {
    return _firestore
        .collection('user_notifications')
        .where('userId', isEqualTo: userId)
        .where('read', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
  
  /// Show in-app notification dialog for status changes
  static void showStatusChangeNotification(
    BuildContext context,
    String title,
    String message,
    String status,
  ) {
    final isApproved = status == 'approved';
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(
                isApproved ? Icons.celebration : Icons.feedback_outlined,
                color: isApproved ? Colors.green : Colors.orange,
                size: 28,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isApproved ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 16, height: 1.4),
          ),
          actions: [
            if (!isApproved)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Navigate to contributions screen for resubmission
                  Navigator.pushNamed(context, '/contributions');
                },
                child: const Text('Resubmit'),
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                isApproved ? 'Praise God!' : 'Understood',
                style: TextStyle(
                  color: isApproved ? Colors.green : Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}