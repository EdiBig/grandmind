/// Form validation utilities
class Validators {
  Validators._();

  /// Validates email format
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validates password strength
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    return null;
  }

  /// Validates password confirmation
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  /// Validates required field
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  /// Validates name (letters, spaces, hyphens only)
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }

    final nameRegex = RegExp(r"^[a-zA-Z\s\-']+$");
    if (!nameRegex.hasMatch(value)) {
      return 'Name can only contain letters, spaces, and hyphens';
    }

    return null;
  }

  /// Validates number within range
  static String? validateNumber(
    String? value, {
    String? fieldName,
    double? min,
    double? max,
  }) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }

    final number = double.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }

    if (min != null && number < min) {
      return '${fieldName ?? 'Value'} must be at least $min';
    }

    if (max != null && number > max) {
      return '${fieldName ?? 'Value'} must be at most $max';
    }

    return null;
  }

  /// Validates weight (in kg)
  static String? validateWeight(String? value) {
    return validateNumber(
      value,
      fieldName: 'Weight',
      min: 30,
      max: 300,
    );
  }

  /// Validates height (in cm)
  static String? validateHeight(String? value) {
    return validateNumber(
      value,
      fieldName: 'Height',
      min: 100,
      max: 250,
    );
  }

  /// Validates age
  static String? validateAge(String? value) {
    return validateNumber(
      value,
      fieldName: 'Age',
      min: 13,
      max: 120,
    );
  }

  /// Validates phone number (basic)
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]+$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }

    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length < 10) {
      return 'Phone number must be at least 10 digits';
    }

    return null;
  }

  // ========== Workout & Exercise Validators ==========

  /// Validates workout duration (in minutes)
  static String? validateDuration(String? value, {bool required = true}) {
    if (value == null || value.isEmpty) {
      return required ? 'Duration is required' : null;
    }
    return validateNumber(value, fieldName: 'Duration', min: 1, max: 1440);
  }

  /// Validates sets count
  static String? validateSets(String? value, {bool required = false}) {
    if (value == null || value.isEmpty) {
      return required ? 'Sets is required' : null;
    }
    final number = int.tryParse(value);
    if (number == null) return 'Please enter a valid number';
    if (number < 1) return 'Sets must be at least 1';
    if (number > 100) return 'Sets cannot exceed 100';
    return null;
  }

  /// Validates reps count
  static String? validateReps(String? value, {bool required = false}) {
    if (value == null || value.isEmpty) {
      return required ? 'Reps is required' : null;
    }
    final number = int.tryParse(value);
    if (number == null) return 'Please enter a valid number';
    if (number < 1) return 'Reps must be at least 1';
    if (number > 500) return 'Reps cannot exceed 500';
    return null;
  }

  /// Validates exercise weight (in kg, 0 = bodyweight)
  static String? validateExerciseWeight(String? value, {bool required = false}) {
    if (value == null || value.isEmpty) {
      return required ? 'Weight is required' : null;
    }
    return validateNumber(value, fieldName: 'Weight', min: 0, max: 500);
  }

  // ========== Mood & Energy Validators ==========

  /// Validates mood/energy scale (1-5)
  static String? validateMoodEnergy(int? value, {String fieldName = 'Value'}) {
    if (value == null) return null; // Optional
    if (value < 1 || value > 5) {
      return '$fieldName must be between 1 and 5';
    }
    return null;
  }

  // ========== Date Validators ==========

  /// Validates date of birth (13-120 years old)
  static String? validateDateOfBirth(DateTime? value) {
    if (value == null) return 'Date of birth is required';

    final now = DateTime.now();
    final age = now.year - value.year -
        ((now.month < value.month ||
          (now.month == value.month && now.day < value.day)) ? 1 : 0);

    if (age < 13) return 'You must be at least 13 years old';
    if (age > 120) return 'Please enter a valid date of birth';
    if (value.isAfter(now)) return 'Date cannot be in the future';

    return null;
  }

  /// Validates that date is not in the future
  static String? validatePastDate(DateTime? value, {String fieldName = 'Date'}) {
    if (value == null) return '$fieldName is required';
    if (value.isAfter(DateTime.now())) {
      return '$fieldName cannot be in the future';
    }
    return null;
  }

  /// Validates date is within a reasonable range (e.g., last year)
  static String? validateRecentDate(DateTime? value, {int maxDaysAgo = 365}) {
    if (value == null) return 'Date is required';

    final now = DateTime.now();
    final minDate = now.subtract(Duration(days: maxDaysAgo));

    if (value.isAfter(now)) return 'Date cannot be in the future';
    if (value.isBefore(minDate)) {
      return 'Date cannot be more than $maxDaysAgo days ago';
    }
    return null;
  }

  // ========== Body Measurement Validators ==========

  /// Validates body measurement (in cm)
  static String? validateBodyMeasurement(
    String? value, {
    required String measurementType,
    bool required = false,
  }) {
    if (value == null || value.isEmpty) {
      return required ? '$measurementType is required' : null;
    }

    final number = double.tryParse(value);
    if (number == null) return 'Please enter a valid number';

    // Define ranges by measurement type
    final ranges = {
      'waist': (min: 40.0, max: 200.0),
      'chest': (min: 50.0, max: 200.0),
      'hips': (min: 40.0, max: 200.0),
      'shoulders': (min: 30.0, max: 80.0),
      'neck': (min: 20.0, max: 60.0),
      'bicep': (min: 15.0, max: 80.0),
      'forearm': (min: 15.0, max: 60.0),
      'thigh': (min: 30.0, max: 100.0),
      'calf': (min: 20.0, max: 70.0),
    };

    final range = ranges[measurementType.toLowerCase()];
    if (range != null) {
      if (number < range.min) {
        return '$measurementType must be at least ${range.min} cm';
      }
      if (number > range.max) {
        return '$measurementType cannot exceed ${range.max} cm';
      }
    } else {
      // Generic range for unknown measurement types
      if (number < 1) return '$measurementType must be greater than 0';
      if (number > 300) return '$measurementType seems too large';
    }

    return null;
  }

  // ========== Nutrition Validators ==========

  /// Validates daily calorie goal
  static String? validateCalories(String? value, {bool required = true}) {
    if (value == null || value.isEmpty) {
      return required ? 'Calories is required' : null;
    }
    final number = int.tryParse(value);
    if (number == null) return 'Please enter a valid number';
    if (number < 500) return 'Daily calories should be at least 500';
    if (number > 10000) return 'Daily calories cannot exceed 10,000';
    return null;
  }

  /// Validates macro nutrients (protein, carbs, fat in grams)
  static String? validateMacro(
    String? value, {
    required String macroName,
    bool required = false,
  }) {
    if (value == null || value.isEmpty) {
      return required ? '$macroName is required' : null;
    }

    final number = double.tryParse(value);
    if (number == null) return 'Please enter a valid number';
    if (number < 0) return '$macroName cannot be negative';

    final maxValues = {
      'protein': 500.0,
      'carbs': 800.0,
      'fat': 400.0,
      'fiber': 100.0,
      'sugar': 300.0,
    };

    final max = maxValues[macroName.toLowerCase()] ?? 1000.0;
    if (number > max) return '$macroName cannot exceed ${max.toInt()}g';

    return null;
  }

  /// Validates water intake (glasses)
  static String? validateWaterGlasses(String? value, {bool required = false}) {
    if (value == null || value.isEmpty) {
      return required ? 'Water intake is required' : null;
    }
    final number = int.tryParse(value);
    if (number == null) return 'Please enter a valid number';
    if (number < 1) return 'Water intake must be at least 1 glass';
    if (number > 30) return 'Water intake cannot exceed 30 glasses';
    return null;
  }

  /// Validates serving size
  static String? validateServings(String? value, {bool required = true}) {
    if (value == null || value.isEmpty) {
      return required ? 'Servings is required' : null;
    }
    final number = double.tryParse(value);
    if (number == null) return 'Please enter a valid number';
    if (number < 0.1) return 'Servings must be at least 0.1';
    if (number > 100) return 'Servings cannot exceed 100';
    return null;
  }

  // ========== Habit Validators ==========

  /// Validates habit target count
  static String? validateTargetCount(String? value, {bool required = false}) {
    if (value == null || value.isEmpty) {
      return required ? 'Target count is required' : null;
    }
    final number = int.tryParse(value);
    if (number == null) return 'Please enter a valid number';
    if (number < 1) return 'Target must be at least 1';
    if (number > 99999) return 'Target cannot exceed 99,999';
    return null;
  }

  // ========== Generic Optional Number Validator ==========

  /// Validates optional number within range
  static String? validateOptionalNumber(
    String? value, {
    String? fieldName,
    double? min,
    double? max,
  }) {
    if (value == null || value.isEmpty) return null;
    return validateNumber(value, fieldName: fieldName, min: min, max: max);
  }
}
