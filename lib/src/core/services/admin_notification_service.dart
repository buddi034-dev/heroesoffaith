import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminNotificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// Get count of pending contributions for admin badge
  static Stream<int> getPendingContributionsCount() {
    return _firestore
        .collection('contributions')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
  
  /// Get all pending contributions for admin review
  static Stream<QuerySnapshot> getPendingContributions() {
    return _firestore
        .collection('contributions')
        .where('status', isEqualTo: 'pending')
        .orderBy('submittedAt', descending: true)
        .snapshots();
  }
  
  /// Check if current user is admin/curator
  static Future<bool> isUserAdminOrCurator() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;
      
      final userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();
      
      if (!userDoc.exists) return false;
      
      final role = userDoc.data()?['role'] ?? 'user';
      return role == 'admin' || role == 'curator';
    } catch (e) {
      debugPrint('Error checking admin role: $e');
      return false;
    }
  }
  
  /// Get user role
  static Future<String> getUserRole() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return 'user';
      
      final userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();
      
      return userDoc.data()?['role'] ?? 'user';
    } catch (e) {
      debugPrint('Error getting user role: $e');
      return 'user';
    }
  }
  
  /// Create notification widget for admin dashboard
  static Widget buildAdminNotificationBadge({
    required Widget child,
    required BuildContext context,
  }) {
    return StreamBuilder<int>(
      stream: getPendingContributionsCount(),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        
        if (count == 0) return child;
        
        return Stack(
          children: [
            child,
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                constraints: const BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                ),
                child: Text(
                  count > 99 ? '99+' : count.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  
  /// Show notification toast for new contributions
  static void showContributionNotification(BuildContext context, int newCount) {
    if (newCount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✨ $newCount new sacred contribution${newCount > 1 ? 's' : ''} awaiting your blessing!',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Review',
            textColor: Colors.white,
            onPressed: () {
              Navigator.pushNamed(context, '/approval-queue');
            },
          ),
        ),
      );
    }
  }
  
  /// Send notification when new contribution is submitted
  static Future<void> notifyAdminsOfNewContribution({
    required String contributionType,
    required String missionaryName,
    required String contributorName,
  }) async {
    try {
      // Create a notification record for admins
      await _firestore.collection('admin_notifications').add({
        'type': 'new_contribution',
        'contributionType': contributionType,
        'missionaryName': missionaryName,
        'contributorName': contributorName,
        'message': '$contributorName submitted a new $contributionType for $missionaryName',
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      });
      
      debugPrint('✅ Admin notification created for new $contributionType contribution');
    } catch (e) {
      debugPrint('❌ Failed to notify admins: $e');
    }
  }
  
  /// Get admin notifications stream
  static Stream<QuerySnapshot> getAdminNotifications() {
    return _firestore
        .collection('admin_notifications')
        .where('read', isEqualTo: false)
        .orderBy('timestamp', descending: true)
        .limit(10)
        .snapshots();
  }
  
  /// Mark notification as read
  static Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('admin_notifications')
          .doc(notificationId)
          .update({'read': true});
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }
}