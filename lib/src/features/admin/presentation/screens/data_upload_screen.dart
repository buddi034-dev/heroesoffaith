import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/json_data_uploader.dart';

/// Screen for uploading JSON data to Firestore
/// Provides validation, backup, and upload functionality
class DataUploadScreen extends StatefulWidget {
  const DataUploadScreen({super.key});

  @override
  State<DataUploadScreen> createState() => _DataUploadScreenState();
}

class _DataUploadScreenState extends State<DataUploadScreen> {
  final JsonDataUploader _uploader = JsonDataUploader();
  
  bool _isLoading = false;
  bool _isValidated = false;
  ValidationResult? _validationResult;
  UploadResult? _uploadResult;
  String? _backupContent;
  
  final String _jsonFilePath = r'C:\Users\HP\AndroidStudioProjects\ChristCommander\herosoffaith\firestoreData.json';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Upload Missionary Data',
          style: GoogleFonts.lato(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
        elevation: 0,
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoCard(),
                const SizedBox(height: 16),
                _buildFilePathCard(),
                const SizedBox(height: 16),
                _buildValidationSection(),
                const SizedBox(height: 16),
                _buildUploadSection(),
                const SizedBox(height: 16),
                if (_uploadResult != null) _buildResultsCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info, color: Colors.blue[600]),
              const SizedBox(width: 8),
              Text(
                'Data Upload Process',
                style: GoogleFonts.lato(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'This tool will upload missionary data from your JSON file to Firestore. Follow these steps:',
            style: GoogleFonts.lato(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          _buildStep('1', 'Validate JSON structure and data quality'),
          _buildStep('2', 'Create backup of existing data (recommended)'),
          _buildStep('3', 'Upload data to Firestore'),
          _buildStep('4', 'Review results and handle any errors'),
        ],
      ),
    );
  }

  Widget _buildStep(String number, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFF667eea),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                number,
                style: GoogleFonts.lato(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              description,
              style: GoogleFonts.lato(
                fontSize: 13,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilePathCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.folder, color: Colors.orange[600]),
              const SizedBox(width: 8),
              Text(
                'JSON File Path',
                style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _jsonFilePath,
              style: GoogleFonts.lato(
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValidationSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.verified,
                color: _isValidated && _validationResult?.isValid == true 
                    ? Colors.green 
                    : Colors.orange[600],
              ),
              const SizedBox(width: 8),
              Text(
                'Step 1: Validate Data',
                style: GoogleFonts.lato(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (!_isValidated) ...[
            Text(
              'Validate your JSON file structure and data quality before uploading.',
              style: GoogleFonts.lato(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _validateData,
                icon: _isLoading 
                    ? const SizedBox(
                        width: 16, 
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.check_circle),
                label: Text(_isLoading ? 'Validating...' : 'Validate JSON Data'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
          
          if (_validationResult != null) ...[
            const SizedBox(height: 16),
            _buildValidationResults(),
          ],
        ],
      ),
    );
  }

  Widget _buildValidationResults() {
    final result = _validationResult!;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: result.isValid ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: result.isValid ? Colors.green[200]! : Colors.red[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                result.isValid ? Icons.check_circle : Icons.error,
                color: result.isValid ? Colors.green[600] : Colors.red[600],
              ),
              const SizedBox(width: 8),
              Text(
                result.isValid ? 'Validation Passed' : 'Validation Failed',
                style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: result.isValid ? Colors.green[800] : Colors.red[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          _buildValidationStat('Total Records', result.totalRecords),
          _buildValidationStat('Valid Records', result.validRecords),
          if (result.errors.isNotEmpty)
            _buildValidationStat('Errors', result.errors.length),
          if (result.warnings.isNotEmpty)
            _buildValidationStat('Warnings', result.warnings.length),
          
          if (result.errors.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Errors:',
              style: GoogleFonts.lato(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.red[800],
              ),
            ),
            ...result.errors.take(5).map((error) => Padding(
              padding: const EdgeInsets.only(left: 8, top: 4),
              child: Text(
                '• $error',
                style: GoogleFonts.lato(
                  fontSize: 12,
                  color: Colors.red[600],
                ),
              ),
            )),
            if (result.errors.length > 5)
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 4),
                child: Text(
                  '... and ${result.errors.length - 5} more errors',
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    color: Colors.red[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
          
          if (result.warnings.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Warnings:',
              style: GoogleFonts.lato(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.orange[800],
              ),
            ),
            ...result.warnings.take(3).map((warning) => Padding(
              padding: const EdgeInsets.only(left: 8, top: 4),
              child: Text(
                '• $warning',
                style: GoogleFonts.lato(
                  fontSize: 12,
                  color: Colors.orange[600],
                ),
              ),
            )),
            if (result.warnings.length > 3)
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 4),
                child: Text(
                  '... and ${result.warnings.length - 3} more warnings',
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    color: Colors.orange[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildValidationStat(String label, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.lato(fontSize: 14),
          ),
          Text(
            value.toString(),
            style: GoogleFonts.lato(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.cloud_upload, color: Colors.blue[600]),
              const SizedBox(width: 8),
              Text(
                'Step 2-3: Backup & Upload',
                style: GoogleFonts.lato(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (!_isValidated || _validationResult?.isValid != true) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange[600], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Please validate your data first before uploading.',
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        color: Colors.orange[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _createBackup,
                    icon: const Icon(Icons.backup),
                    label: const Text('Create Backup'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _uploadData,
                    icon: _isLoading 
                        ? const SizedBox(
                            width: 16, 
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.upload),
                    label: Text(_isLoading ? 'Uploading...' : 'Upload Data'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF667eea),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            
            if (_backupContent != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green[600], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Backup created successfully. Your existing data is safe.',
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          color: Colors.green[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildResultsCard() {
    final result = _uploadResult!;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                result.success ? Icons.check_circle : Icons.error,
                color: result.success ? Colors.green[600] : Colors.red[600],
              ),
              const SizedBox(width: 8),
              Text(
                'Upload Results',
                style: GoogleFonts.lato(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: result.success ? Colors.green[50] : Colors.red[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: result.success ? Colors.green[200]! : Colors.red[200]!,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.message,
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: result.success ? Colors.green[800] : Colors.red[800],
                  ),
                ),
                const SizedBox(height: 12),
                
                if (result.uploadedCount > 0)
                  _buildResultStat('New Records Created', result.uploadedCount, Colors.blue),
                if (result.updatedCount > 0)
                  _buildResultStat('Records Updated', result.updatedCount, Colors.orange),
                if (result.errors.isNotEmpty)
                  _buildResultStat('Errors', result.errors.length, Colors.red),
                
                if (result.errors.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Errors encountered:',
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[800],
                    ),
                  ),
                  ...result.errors.take(3).map((error) => Padding(
                    padding: const EdgeInsets.only(left: 8, top: 4),
                    child: Text(
                      '• $error',
                      style: GoogleFonts.lato(
                        fontSize: 12,
                        color: Colors.red[600],
                      ),
                    ),
                  )),
                  if (result.errors.length > 3)
                    Padding(
                      padding: const EdgeInsets.only(left: 8, top: 4),
                      child: Text(
                        '... and ${result.errors.length - 3} more errors',
                        style: GoogleFonts.lato(
                          fontSize: 12,
                          color: Colors.red[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultStat(String label, int value, MaterialColor color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.lato(fontSize: 14),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value.toString(),
              style: GoogleFonts.lato(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _validateData() async {
    setState(() {
      _isLoading = true;
      _isValidated = false;
      _validationResult = null;
    });

    try {
      // Read and validate the JSON file
      final file = await File(_jsonFilePath).readAsString();
      final result = _uploader.validateJsonStructure(file);
      
      setState(() {
        _validationResult = result;
        _isValidated = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.isValid ? 'Validation passed!' : 'Validation failed - check errors'),
          backgroundColor: result.isValid ? Colors.green : Colors.red,
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to validate: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createBackup() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final backup = await _uploader.backupExistingData();
      setState(() {
        _backupContent = backup;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Backup created successfully!'),
          backgroundColor: Colors.green,
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create backup: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _uploadData() async {
    setState(() {
      _isLoading = true;
      _uploadResult = null;
    });

    try {
      final result = await _uploader.uploadFromJsonFile(_jsonFilePath);
      
      setState(() {
        _uploadResult = result;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.success ? 'Upload completed successfully!' : 'Upload completed with errors'),
          backgroundColor: result.success ? Colors.green : Colors.orange,
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}