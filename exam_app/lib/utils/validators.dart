class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }

    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }

    if (value.length > 20) {
      return 'Username must be less than 20 characters';
    }

    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+');
    if (!usernameRegex.hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores';
    }

    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateJoinCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Join code is required';
    }

    if (value.length != 6) {
      return 'Join code must be exactly 6 characters';
    }

    final codeRegex = RegExp(r'^[A-Z0-9]{6}');
    if (!codeRegex.hasMatch(value.toUpperCase())) {
      return 'Join code can only contain letters and numbers';
    }

    return null;
  }

  static String? validatePositiveInteger(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    final intValue = int.tryParse(value);
    if (intValue == null || intValue <= 0) {
      return '$fieldName must be a positive number';
    }

    return null;
  }

  static String? validateTimeLimit(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    final intValue = int.tryParse(value);
    if (intValue == null || intValue <= 0) {
      return 'Time limit must be a positive number';
    }

    if (intValue > 300) {
      return 'Time limit cannot exceed 300 minutes (5 hours)';
    }

    return null;
  }
}
