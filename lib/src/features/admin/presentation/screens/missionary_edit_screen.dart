import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../models/missionary.dart';
import '../../../core/services/firestore_service.dart';

/// Screen for editing missionary information
/// This is a simple example of how to update Firestore data
class MissionaryEditScreen extends StatefulWidget {
  final Missionary missionary;

  const MissionaryEditScreen({
    super.key,
    required this.missionary,
  });

  @override
  State<MissionaryEditScreen> createState() => _MissionaryEditScreenState();
}

class _MissionaryEditScreenState extends State<MissionaryEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();
  
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _fieldController;
  late TextEditingController _countryController;
  late TextEditingController _centuryController;
  late TextEditingController _imageUrlController;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.missionary.fullName);
    _bioController = TextEditingController(text: widget.missionary.bio ?? '');
    _fieldController = TextEditingController(text: widget.missionary.fieldOfService ?? '');
    _countryController = TextEditingController(text: widget.missionary.countryOfService ?? '');
    _centuryController = TextEditingController(text: widget.missionary.century ?? '');
    _imageUrlController = TextEditingController(text: widget.missionary.heroImageUrl);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _fieldController.dispose();
    _countryController.dispose();
    _centuryController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _updateMissionary() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedMissionary = widget.missionary.copyWith(
        fullName: _nameController.text.trim(),
        bio: _bioController.text.trim(),
        fieldOfService: _fieldController.text.trim(),
        countryOfService: _countryController.text.trim(),
        century: _centuryController.text.trim(),
        heroImageUrl: _imageUrlController.text.trim(),
      );

      // Update using the FirestoreService
      await _firestoreService.updateMissionary(
        widget.missionary.id,
        updatedMissionary,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Missionary updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(updatedMissionary);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update missionary: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateSpecificField(String fieldName, String value) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _firestoreService.updateMissionaryFields(
        widget.missionary.id,
        {fieldName: value},
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$fieldName updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update $fieldName: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteMissionary() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Missionary'),
        content: Text('Are you sure you want to delete ${widget.missionary.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _firestoreService.deleteMissionary(widget.missionary.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Missionary deleted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete missionary: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Missionary',
          style: GoogleFonts.lato(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _deleteMissionary,
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Missionary Information',
                            style: GoogleFonts.lato(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF667eea),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          _buildTextField(
                            controller: _nameController,
                            label: 'Full Name',
                            icon: Icons.person,
                            required: true,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          _buildTextField(
                            controller: _bioController,
                            label: 'Biography',
                            icon: Icons.book,
                            maxLines: 4,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          _buildTextField(
                            controller: _fieldController,
                            label: 'Field of Service',
                            icon: Icons.work,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          _buildTextField(
                            controller: _countryController,
                            label: 'Country of Service',
                            icon: Icons.public,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          _buildTextField(
                            controller: _centuryController,
                            label: 'Century',
                            icon: Icons.calendar_today,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          _buildTextField(
                            controller: _imageUrlController,
                            label: 'Image URL',
                            icon: Icons.image,
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Quick action buttons
                          Text(
                            'Quick Actions',
                            style: GoogleFonts.lato(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF667eea),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _isLoading
                                      ? null
                                      : () => _updateSpecificField('bio', _bioController.text.trim()),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Update Bio Only'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _isLoading
                                      ? null
                                      : () => _updateSpecificField('fieldOfService', _fieldController.text.trim()),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.purple,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Update Field'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
              // Action buttons
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.lato(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _updateMissionary,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF667eea),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Save Changes',
                                style: GoogleFonts.lato(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool required = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
        ),
      ),
      validator: required
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return '$label is required';
              }
              return null;
            }
          : null,
    );
  }
}