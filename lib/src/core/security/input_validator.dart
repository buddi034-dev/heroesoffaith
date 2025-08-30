import 'dart:convert';

class InputValidator {
  // Dangerous patterns that could indicate code injection attempts
  static final List<RegExp> _dangerousPatterns = [
    // Script tags
    RegExp(r'<script[^>]*>.*?</script>', caseSensitive: false),
    RegExp(r'javascript:', caseSensitive: false),
    RegExp(r'vbscript:', caseSensitive: false),
    RegExp(r'onload\s*=', caseSensitive: false),
    RegExp(r'onerror\s*=', caseSensitive: false),
    RegExp(r'onclick\s*=', caseSensitive: false),
    
    // SQL injection patterns
    RegExp(r'(union|select|insert|update|delete|drop|alter)\s+', caseSensitive: false),
    RegExp(r'--\s*$', multiLine: true), // SQL comments
    RegExp(r'/\*.*?\*/', dotAll: true), // SQL block comments
    
    // Command injection patterns
    RegExp(r'[;&|`$()]'),
    RegExp(r'(rm|del|format|shutdown|reboot)\s+', caseSensitive: false),
    
    // XSS patterns
    RegExp(r'<[^>]+on\w+\s*=', caseSensitive: false),
    RegExp(r'<(iframe|embed|object|applet|form)', caseSensitive: false),
    
    // File path traversal
    RegExp(r'\.\.[\\/]'),
    RegExp(r'[\\/]etc[\\/]'),
    RegExp(r'[\\/]proc[\\/]'),
    
    // Encoding evasion attempts
    RegExp(r'%[0-9a-fA-F]{2}'), // URL encoding
    RegExp(r'&#\d+;'), // HTML entities
    RegExp(r'&#x[0-9a-fA-F]+;'), // Hex HTML entities
  ];

  // Characters that should be escaped or removed
  static final RegExp _htmlSpecialChars = RegExp(r'''[<>&"'`]''');
  static final RegExp _controlChars = RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F-\x9F]');
  
  /// Validate and sanitize user input for contributions
  static ValidationResult validateContributionText(String input, {int maxLength = 5000}) {
    if (input.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        cleanedInput: '',
        errors: ['Content cannot be empty'],
      );
    }
    
    final List<String> errors = [];
    String cleanedInput = input.trim();
    
    // Check length
    if (cleanedInput.length > maxLength) {
      errors.add('Content exceeds maximum length of $maxLength characters');
      cleanedInput = cleanedInput.substring(0, maxLength);
    }
    
    // Check for dangerous patterns
    for (final pattern in _dangerousPatterns) {
      if (pattern.hasMatch(cleanedInput)) {
        errors.add('Content contains potentially dangerous code. Please use plain text only.');
        // Remove dangerous patterns
        cleanedInput = cleanedInput.replaceAll(pattern, '[REMOVED]');
      }
    }
    
    // Remove control characters
    cleanedInput = cleanedInput.replaceAll(_controlChars, '');
    
    // Escape HTML special characters for safety
    cleanedInput = _escapeHtml(cleanedInput);
    
    // Additional validation for spiritual content
    if (cleanedInput.length < 10) {
      errors.add('Please provide more detailed content (at least 10 characters)');
    }
    
    return ValidationResult(
      isValid: errors.isEmpty,
      cleanedInput: cleanedInput,
      errors: errors,
      originalLength: input.length,
      cleanedLength: cleanedInput.length,
    );
  }
  
  /// Validate title input
  static ValidationResult validateTitle(String input, {int maxLength = 100}) {
    if (input.trim().isEmpty) {
      return ValidationResult(
        isValid: true, // Title is optional
        cleanedInput: '',
        errors: [],
      );
    }
    
    final List<String> errors = [];
    String cleanedInput = input.trim();
    
    // Check length
    if (cleanedInput.length > maxLength) {
      errors.add('Title exceeds maximum length of $maxLength characters');
      cleanedInput = cleanedInput.substring(0, maxLength);
    }
    
    // Check for dangerous patterns
    for (final pattern in _dangerousPatterns) {
      if (pattern.hasMatch(cleanedInput)) {
        errors.add('Title contains potentially dangerous content');
        cleanedInput = cleanedInput.replaceAll(pattern, '[REMOVED]');
      }
    }
    
    // Remove control characters and escape HTML
    cleanedInput = cleanedInput.replaceAll(_controlChars, '');
    cleanedInput = _escapeHtml(cleanedInput);
    
    return ValidationResult(
      isValid: errors.isEmpty,
      cleanedInput: cleanedInput,
      errors: errors,
    );
  }
  
  /// Validate image caption
  static ValidationResult validateCaption(String input, {int maxLength = 500}) {
    return validateContributionText(input, maxLength: maxLength);
  }
  
  /// Escape HTML special characters
  static String _escapeHtml(String input) {
    return input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;')
        .replaceAll('`', '&#x60;');
  }
  
  /// Check if string contains only safe characters for display
  static bool isSafeForDisplay(String input) {
    // Allow letters, numbers, common punctuation, and basic formatting
    final safePattern = RegExp(r'''^[a-zA-Z0-9\s.,!?;:()\[\]{}"'`\-_+=@#$%^&*~/\\|\r\n]*$''');
    return safePattern.hasMatch(input) && !_containsDangerousPatterns(input);
  }
  
  /// Check for dangerous patterns
  static bool _containsDangerousPatterns(String input) {
    return _dangerousPatterns.any((pattern) => pattern.hasMatch(input));
  }
  
  /// Validate base64 image data
  static bool isValidBase64Image(String base64String) {
    try {
      final bytes = base64Decode(base64String);
      
      // Check file size (max 2MB)
      if (bytes.length > 2 * 1024 * 1024) return false;
      
      // Check for common image file signatures
      if (bytes.length < 8) return false;
      
      // JPEG signature
      if (bytes[0] == 0xFF && bytes[1] == 0xD8) return true;
      
      // PNG signature
      if (bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47) return true;
      
      // GIF signature
      if (bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46) return true;
      
      // WebP signature
      if (bytes[0] == 0x52 && bytes[1] == 0x49 && bytes[2] == 0x46 && bytes[3] == 0x46 &&
          bytes[8] == 0x57 && bytes[9] == 0x45 && bytes[10] == 0x42 && bytes[11] == 0x50) return true;
      
      return false;
    } catch (e) {
      return false;
    }
  }
}

class ValidationResult {
  final bool isValid;
  final String cleanedInput;
  final List<String> errors;
  final int? originalLength;
  final int? cleanedLength;
  
  ValidationResult({
    required this.isValid,
    required this.cleanedInput,
    required this.errors,
    this.originalLength,
    this.cleanedLength,
  });
  
  bool get hasWarnings => cleanedLength != null && originalLength != null && cleanedLength! < originalLength!;
  
  String get warningMessage {
    if (!hasWarnings) return '';
    final removedChars = originalLength! - cleanedLength!;
    return 'Removed $removedChars potentially unsafe characters from your input.';
  }
}