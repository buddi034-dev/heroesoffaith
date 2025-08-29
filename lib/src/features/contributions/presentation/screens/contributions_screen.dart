import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../core/constants/spiritual_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/github_image_service.dart';
import '../../../../core/services/admin_notification_service.dart';
import '../../../../core/security/input_validator.dart';
import '../../../common/presentation/widgets/loading_widget.dart';

class ContributionsScreen extends StatefulWidget {
  final String? missionaryId;
  final String? missionaryName;

  const ContributionsScreen({
    super.key,
    this.missionaryId,
    this.missionaryName,
  });

  @override
  State<ContributionsScreen> createState() => _ContributionsScreenState();
}

class _ContributionsScreenState extends State<ContributionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _photoFormKey = GlobalKey<FormState>();
  final _anecdoteFormKey = GlobalKey<FormState>();
  
  // Form controllers
  final _anecdoteController = TextEditingController();
  final _captionController = TextEditingController();
  final _titleController = TextEditingController();
  
  // State variables
  File? _selectedImage;
  bool _isSubmitting = false;
  bool _isAnonymous = false;
  String _selectedMissionaryId = '';
  String _selectedMissionaryName = '';
  
  // Available missionaries for selection
  List<Map<String, String>> _missionaries = [];
  bool _loadingMissionaries = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedMissionaryId = widget.missionaryId ?? '';
    _selectedMissionaryName = widget.missionaryName ?? '';
    _loadMissionaries();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _anecdoteController.dispose();
    _captionController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _loadMissionaries() async {
    try {
      // Load missionaries from API or Firebase
      // For now, using some default options
      _missionaries = [
        {'id': 'william-carey', 'name': 'William Carey'},
        {'id': 'hudson-taylor', 'name': 'Hudson Taylor'},
        {'id': 'amy-carmichael', 'name': 'Amy Carmichael'},
        {'id': 'ida-scudder', 'name': 'Dr. Ida Scudder'},
        {'id': 'alexander-duff', 'name': 'Alexander Duff'},
        {'id': 'pandita-ramabai', 'name': 'Pandita Ramabai'},
      ];
      
      if (_selectedMissionaryId.isEmpty && _missionaries.isNotEmpty) {
        _selectedMissionaryId = _missionaries.first['id']!;
        _selectedMissionaryName = _missionaries.first['name']!;
      }
    } catch (e) {
      debugPrint('Error loading missionaries: $e');
    } finally {
      setState(() => _loadingMissionaries = false);
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error selecting image: $e');
    }
  }

  Future<void> _submitPhotoContribution() async {
    if (!_photoFormKey.currentState!.validate() || _selectedImage == null) {
      _showErrorSnackBar('Please select an image and provide a caption');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showErrorSnackBar('Please sign in to submit contributions');
        return;
      }

      // Validate and sanitize all text inputs
      final titleValidation = InputValidator.validateTitle(_titleController.text);
      final captionValidation = InputValidator.validateCaption(_captionController.text);
      
      if (!titleValidation.isValid || !captionValidation.isValid) {
        final allErrors = [...titleValidation.errors, ...captionValidation.errors];
        _showErrorSnackBar('🛡️ Security validation failed: ${allErrors.join(', ')}');
        return;
      }

      // Save image with base64 encoding for admin review  
      final imageData = await GitHubImageService.saveImageToGitHub(
        imageFile: _selectedImage!,
        userId: user.uid,
        missionaryName: _selectedMissionaryName,
        contributionType: 'photo',
      );

      // Validate base64 image data
      if (!InputValidator.isValidBase64Image(imageData['base64Image']!)) {
        _showErrorSnackBar('🛡️ Invalid image format detected. Please select a valid image.');
        return;
      }

      // Save contribution to Firestore with sanitized inputs
      await FirebaseFirestore.instance.collection('contributions').add({
        'type': 'photo',
        'missionaryId': _selectedMissionaryId,
        'missionaryName': _selectedMissionaryName,
        'imageData': imageData['base64Image'], // Validated base64
        'localImagePath': imageData['localPath'], // Local backup
        'fileName': imageData['fileName'],
        'originalFileName': _selectedImage!.path.split('/').last,
        'caption': captionValidation.cleanedInput, // Sanitized caption
        'title': titleValidation.cleanedInput, // Sanitized title
        'contributedBy': user.uid,
        'contributorName': _isAnonymous ? 'Anonymous' : (user.displayName ?? 'A faithful servant'),
        'contributorEmail': user.email,
        'status': 'pending',
        'submittedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'securityValidated': true, // Mark as security validated
      });
      
      // Show warnings if content was sanitized
      if (titleValidation.hasWarnings) {
        _showWarningSnackBar('Title: ${titleValidation.warningMessage}');
      }
      if (captionValidation.hasWarnings) {
        _showWarningSnackBar('Caption: ${captionValidation.warningMessage}');
      }

      // Notify admins of new contribution
      AdminNotificationService.notifyAdminsOfNewContribution(
        contributionType: 'Sacred Image',
        missionaryName: _selectedMissionaryName,
        contributorName: user.displayName ?? 'A faithful servant',
      );

      _showSuccessSnackBar('${SpiritualStrings.wellDone} Your photo has been submitted for blessing');
      _resetPhotoForm();
    } catch (e) {
      String errorMessage = '${SpiritualStrings.errorOccurred}';
      if (e.toString().contains('too large') || e.toString().contains('document too large')) {
        errorMessage = 'Image is too large. Please select a smaller image.';
      } else if (e.toString().contains('Permission denied')) {
        errorMessage = 'Permission denied. Please ensure you are signed in.';
      }
      _showErrorSnackBar(errorMessage);
      debugPrint('Photo upload error: $e');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _submitAnecdoteContribution() async {
    if (!_anecdoteFormKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showErrorSnackBar('Please sign in to submit contributions');
        return;
      }

      // Validate and sanitize all text inputs
      final titleValidation = InputValidator.validateTitle(_titleController.text);
      final contentValidation = InputValidator.validateContributionText(_anecdoteController.text);
      
      if (!titleValidation.isValid || !contentValidation.isValid) {
        final allErrors = [...titleValidation.errors, ...contentValidation.errors];
        _showErrorSnackBar('🛡️ Security validation failed: ${allErrors.join(', ')}');
        return;
      }

      // Save contribution to Firestore with sanitized inputs
      await FirebaseFirestore.instance.collection('contributions').add({
        'type': 'anecdote',
        'missionaryId': _selectedMissionaryId,
        'missionaryName': _selectedMissionaryName,
        'content': contentValidation.cleanedInput, // Sanitized content
        'title': titleValidation.cleanedInput, // Sanitized title
        'contributedBy': user.uid,
        'contributorName': _isAnonymous ? 'Anonymous' : (user.displayName ?? 'A faithful servant'),
        'contributorEmail': user.email,
        'status': 'pending',
        'submittedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'securityValidated': true, // Mark as security validated
      });
      
      // Show warnings if content was sanitized
      if (titleValidation.hasWarnings) {
        _showWarningSnackBar('Title: ${titleValidation.warningMessage}');
      }
      if (contentValidation.hasWarnings) {
        _showWarningSnackBar('Story: ${contentValidation.warningMessage}');
      }

      // Notify admins of new contribution
      AdminNotificationService.notifyAdminsOfNewContribution(
        contributionType: 'Story of Faith',
        missionaryName: _selectedMissionaryName,
        contributorName: user.displayName ?? 'A faithful servant',
      );

      _showSuccessSnackBar('${SpiritualStrings.wellDone} Your story has been submitted for blessing');
      _resetAnecdoteForm();
    } catch (e) {
      _showErrorSnackBar('${SpiritualStrings.errorOccurred}: $e');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _resetPhotoForm() {
    setState(() {
      _selectedImage = null;
      _captionController.clear();
      _titleController.clear();
    });
  }

  void _resetAnecdoteForm() {
    setState(() {
      _anecdoteController.clear();
      _titleController.clear();
    });
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green[600],
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[600],
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showWarningSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.security, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.orange[600],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Sacred Testimonies'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(
              icon: Icon(Icons.photo_camera),
              text: 'Sacred Images',
            ),
            Tab(
              icon: Icon(Icons.book),
              text: 'Stories of Faith',
            ),
          ],
        ),
      ),
      body: _loadingMissionaries
          ? LoadingWidget()
          : TabBarView(
              controller: _tabController,
              children: [
                _buildPhotoSubmissionTab(),
                _buildAnecdoteSubmissionTab(),
              ],
            ),
    );
  }

  Widget _buildPhotoSubmissionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _photoFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Share Sacred Images',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Help preserve the legacy of faithful servants by sharing historical photographs, documents, or artifacts.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            _buildMissionarySelector(),
            
            const SizedBox(height: 16),
            _buildImagePicker(),
            
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title (Optional)',
                hintText: 'e.g., William Carey at Serampore',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.grey[400]!, width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.grey[400]!, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: AppColors.primaryColor, width: 2.0),
                ),
              ),
              maxLength: 100,
            ),
            
            const SizedBox(height: 16),
            TextFormField(
              controller: _captionController,
              decoration: InputDecoration(
                labelText: 'Caption & Description',
                hintText: 'Describe the image and its significance...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.grey[400]!, width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.grey[400]!, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: AppColors.primaryColor, width: 2.0),
                ),
              ),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please provide a caption for this sacred image';
                }
                if (value.trim().length < 10) {
                  return 'Please provide a more detailed description';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            _buildAnonymousCheckbox(),
            
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitPhotoContribution,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Submit Sacred Image',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnecdoteSubmissionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _anecdoteFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Share Stories of Faith',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Share personal stories, family memories, or historical accounts about these faithful servants.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            _buildMissionarySelector(),
            
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Story Title',
                hintText: 'e.g., My Grandmother\'s Account of Amy Carmichael',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.grey[400]!, width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.grey[400]!, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: AppColors.primaryColor, width: 2.0),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please provide a title for your story';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            TextFormField(
              controller: _anecdoteController,
              decoration: InputDecoration(
                labelText: 'Your Story',
                hintText: 'Share your story, memory, or historical account...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.grey[400]!, width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.grey[400]!, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: AppColors.primaryColor, width: 2.0),
                ),
              ),
              maxLines: 8,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please share your story of faith';
                }
                if (value.trim().length < 50) {
                  return 'Please provide a more detailed story (at least 50 characters)';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            _buildAnonymousCheckbox(),
            
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitAnecdoteContribution,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Submit Story of Faith',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionarySelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Missionary',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedMissionaryId.isEmpty ? null : _selectedMissionaryId,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: _missionaries.map((missionary) {
                return DropdownMenuItem<String>(
                  value: missionary['id']!,
                  child: Text(missionary['name']!),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedMissionaryId = newValue;
                    _selectedMissionaryName = _missionaries
                        .firstWhere((m) => m['id'] == newValue)['name']!;
                  });
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a missionary';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_selectedImage != null) ...[
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    _selectedImage!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.photo_library),
              label: Text(_selectedImage == null ? 'Choose Sacred Image' : 'Change Image'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentColor,
                foregroundColor: Colors.white,
              ),
            ),
            if (_selectedImage == null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Please select an image to share',
                  style: TextStyle(color: Colors.red[600], fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnonymousCheckbox() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Checkbox(
              value: _isAnonymous,
              onChanged: (bool? value) {
                setState(() {
                  _isAnonymous = value ?? false;
                });
              },
              activeColor: AppColors.primaryColor,
            ),
            Expanded(
              child: Text(
                'Submit anonymously (your contribution will be shown as "A faithful servant")',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}