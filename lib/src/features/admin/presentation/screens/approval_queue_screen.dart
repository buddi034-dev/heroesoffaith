import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../../../../core/constants/spiritual_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/admin_notification_service.dart';
import '../../../common/presentation/widgets/loading_widget.dart';

class ApprovalQueueScreen extends StatefulWidget {
  const ApprovalQueueScreen({super.key});

  @override
  State<ApprovalQueueScreen> createState() => _ApprovalQueueScreenState();
}

class _ApprovalQueueScreenState extends State<ApprovalQueueScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _userRole = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _checkUserRole();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildBase64Image(String base64String) {
    try {
      final bytes = base64Decode(base64String);
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[200],
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image, color: Colors.grey, size: 48),
                SizedBox(height: 8),
                Text('Failed to load image', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      return Container(
        color: Colors.grey[200],
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 48),
              SizedBox(height: 8),
              Text('Invalid image format', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      );
    }
  }

  Future<void> _checkUserRole() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        
        if (userDoc.exists) {
          _userRole = userDoc.data()?['role'] ?? 'user';
        }
      }
    } catch (e) {
      debugPrint('Error checking user role: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  bool get _canApprove => _userRole == 'curator' || _userRole == 'admin';

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: LoadingWidget(),
      );
    }

    if (!_canApprove) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Access Denied'),
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'Sacred Curator Access Required',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Only blessed curators and administrators can access the approval sanctuary.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Curator\'s Sacred Review'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(
              icon: Icon(Icons.pending_actions),
              text: 'Awaiting Blessing',
            ),
            Tab(
              icon: Icon(Icons.check_circle),
              text: 'Blessed',
            ),
            Tab(
              icon: Icon(Icons.cancel),
              text: 'Declined',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildContributionsList('pending'),
          _buildContributionsList('approved'),
          _buildContributionsList('rejected'),
        ],
      ),
    );
  }

  Widget _buildContributionsList(String status) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('contributions')
          .where('status', isEqualTo: status)
          .orderBy('submittedAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('${SpiritualStrings.errorOccurred}: ${snapshot.error}'),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingWidget();
        }

        final contributions = snapshot.data?.docs ?? [];

        if (contributions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  status == 'pending' ? Icons.inbox : 
                  status == 'approved' ? Icons.check_circle_outline : Icons.cancel_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  _getEmptyStateMessage(status),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getEmptyStateSubtitle(status),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: contributions.length,
          itemBuilder: (context, index) {
            final contribution = contributions[index];
            final data = contribution.data() as Map<String, dynamic>;
            
            return _buildContributionCard(contribution.id, data, status);
          },
        );
      },
    );
  }

  Widget _buildContributionCard(String contributionId, Map<String, dynamic> data, String currentStatus) {
    final isPhoto = data['type'] == 'photo';
    final submittedAt = (data['submittedAt'] as Timestamp?)?.toDate();
    final isPending = currentStatus == 'pending';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with type and missionary
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPhoto ? Colors.blue[100] : Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isPhoto ? 'Sacred Image' : 'Story of Faith',
                    style: TextStyle(
                      color: isPhoto ? Colors.blue[800] : Colors.green[800],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    data['missionaryName'] ?? 'Unknown Missionary',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                _buildStatusBadge(currentStatus),
              ],
            ),

            const SizedBox(height: 12),

            // Title
            if (data['title'] != null && data['title'].toString().isNotEmpty)
              Text(
                data['title'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),

            const SizedBox(height: 8),

            // Content
            if (isPhoto) ...[
              // Photo contribution
              if (data['imageData'] != null || data['imageUrl'] != null)
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: data['imageData'] != null
                        ? _buildBase64Image(data['imageData'])
                        : CachedNetworkImage(
                            imageUrl: data['imageUrl'] ?? '',
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(Icons.error, color: Colors.red),
                              ),
                            ),
                          ),
                  ),
                ),
              const SizedBox(height: 8),
              if (data['caption'] != null)
                Text(
                  data['caption'],
                  style: const TextStyle(fontSize: 14),
                ),
            ] else ...[
              // Anecdote contribution
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  data['content'] ?? '',
                  style: const TextStyle(fontSize: 14),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],

            const SizedBox(height: 12),

            // Contributor info
            Row(
              children: [
                Icon(Icons.person_outline, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'By: ${data['contributorName'] ?? 'Unknown'}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                if (submittedAt != null)
                  Text(
                    _formatDate(submittedAt),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
              ],
            ),

            // Action buttons for pending contributions
            if (isPending) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateContributionStatus(contributionId, 'approved'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Bless & Approve'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateContributionStatus(contributionId, 'rejected'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Decline'),
                    ),
                  ),
                ],
              ),
            ] else if (currentStatus == 'approved') ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _updateContributionStatus(contributionId, 'rejected'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[600],
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.undo, size: 16),
                label: const Text('Revoke Approval'),
              ),
            ] else if (currentStatus == 'rejected') ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _updateContributionStatus(contributionId, 'approved'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.undo, size: 16),
                label: const Text('Restore & Approve'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    IconData icon;
    String label;

    switch (status) {
      case 'approved':
        color = Colors.green;
        icon = Icons.check_circle;
        label = 'Blessed';
        break;
      case 'rejected':
        color = Colors.red;
        icon = Icons.cancel;
        label = 'Declined';
        break;
      default:
        color = Colors.orange;
        icon = Icons.hourglass_empty;
        label = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateContributionStatus(String contributionId, String newStatus) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('contributions')
          .doc(contributionId)
          .update({
        'status': newStatus,
        'reviewedBy': user.uid,
        'reviewerName': user.displayName ?? 'Sacred Curator',
        'reviewedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final statusMessage = newStatus == 'approved' 
          ? 'Contribution blessed and approved!'
          : 'Contribution declined';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(statusMessage),
          backgroundColor: newStatus == 'approved' ? Colors.green[600] : Colors.red[600],
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${SpiritualStrings.errorOccurred}: $e'),
          backgroundColor: Colors.red[600],
        ),
      );
    }
  }

  String _getEmptyStateMessage(String status) {
    switch (status) {
      case 'pending':
        return 'No contributions await your blessing';
      case 'approved':
        return 'No blessed contributions yet';
      case 'rejected':
        return 'No declined contributions';
      default:
        return 'No contributions found';
    }
  }

  String _getEmptyStateSubtitle(String status) {
    switch (status) {
      case 'pending':
        return 'When faithful servants submit their treasures, they will appear here for your sacred review.';
      case 'approved':
        return 'Blessed contributions will be displayed here for the community to cherish.';
      case 'rejected':
        return 'Declined contributions are stored here for record keeping.';
      default:
        return 'Contributions will appear here when available.';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return 'Just now';
    }
  }
}