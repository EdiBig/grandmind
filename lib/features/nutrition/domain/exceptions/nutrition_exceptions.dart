/// Base exception for all nutrition-related errors
class NutritionException implements Exception {
  final String message;
  final String? userMessage;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const NutritionException({
    required this.message,
    this.userMessage,
    this.originalError,
    this.stackTrace,
  });

  /// User-friendly message to display in UI
  String get displayMessage => userMessage ?? 'Something went wrong. Please try again.';

  @override
  String toString() => 'NutritionException: $message';
}

/// Exception for meal-related operations
class MealException extends NutritionException {
  const MealException({
    required super.message,
    super.userMessage,
    super.originalError,
    super.stackTrace,
  });

  factory MealException.logFailed(dynamic error, [StackTrace? stackTrace]) {
    return MealException(
      message: 'Failed to log meal: $error',
      userMessage: 'Unable to save your meal. Please check your connection and try again.',
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  factory MealException.updateFailed(dynamic error, [StackTrace? stackTrace]) {
    return MealException(
      message: 'Failed to update meal: $error',
      userMessage: 'Unable to update your meal. Please try again.',
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  factory MealException.deleteFailed(dynamic error, [StackTrace? stackTrace]) {
    return MealException(
      message: 'Failed to delete meal: $error',
      userMessage: 'Unable to delete this meal. Please try again.',
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  factory MealException.notFound(String mealId) {
    return MealException(
      message: 'Meal not found: $mealId',
      userMessage: 'This meal could not be found. It may have been deleted.',
    );
  }

  factory MealException.fetchFailed(dynamic error, [StackTrace? stackTrace]) {
    return MealException(
      message: 'Failed to fetch meals: $error',
      userMessage: 'Unable to load your meals. Please check your connection.',
      originalError: error,
      stackTrace: stackTrace,
    );
  }
}

/// Exception for water log operations
class WaterLogException extends NutritionException {
  const WaterLogException({
    required super.message,
    super.userMessage,
    super.originalError,
    super.stackTrace,
  });

  factory WaterLogException.saveFailed(dynamic error, [StackTrace? stackTrace]) {
    return WaterLogException(
      message: 'Failed to save water log: $error',
      userMessage: 'Unable to save your water intake. Please try again.',
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  factory WaterLogException.fetchFailed(dynamic error, [StackTrace? stackTrace]) {
    return WaterLogException(
      message: 'Failed to fetch water log: $error',
      userMessage: 'Unable to load your water intake data.',
      originalError: error,
      stackTrace: stackTrace,
    );
  }
}

/// Exception for food item operations
class FoodItemException extends NutritionException {
  const FoodItemException({
    required super.message,
    super.userMessage,
    super.originalError,
    super.stackTrace,
  });

  factory FoodItemException.createFailed(dynamic error, [StackTrace? stackTrace]) {
    return FoodItemException(
      message: 'Failed to create food item: $error',
      userMessage: 'Unable to save this food. Please try again.',
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  factory FoodItemException.updateFailed(dynamic error, [StackTrace? stackTrace]) {
    return FoodItemException(
      message: 'Failed to update food item: $error',
      userMessage: 'Unable to update this food. Please try again.',
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  factory FoodItemException.deleteFailed(dynamic error, [StackTrace? stackTrace]) {
    return FoodItemException(
      message: 'Failed to delete food item: $error',
      userMessage: 'Unable to delete this food. Please try again.',
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  factory FoodItemException.searchFailed(dynamic error, [StackTrace? stackTrace]) {
    return FoodItemException(
      message: 'Failed to search foods: $error',
      userMessage: 'Unable to search foods. Please try again.',
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  factory FoodItemException.notFound(String barcode) {
    return FoodItemException(
      message: 'Food item not found for barcode: $barcode',
      userMessage: 'This product was not found. Try searching by name or add it manually.',
    );
  }
}

/// Exception for nutrition goal operations
class NutritionGoalException extends NutritionException {
  const NutritionGoalException({
    required super.message,
    super.userMessage,
    super.originalError,
    super.stackTrace,
  });

  factory NutritionGoalException.saveFailed(dynamic error, [StackTrace? stackTrace]) {
    return NutritionGoalException(
      message: 'Failed to save nutrition goal: $error',
      userMessage: 'Unable to save your nutrition goals. Please try again.',
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  factory NutritionGoalException.fetchFailed(dynamic error, [StackTrace? stackTrace]) {
    return NutritionGoalException(
      message: 'Failed to fetch nutrition goal: $error',
      userMessage: 'Unable to load your nutrition goals.',
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  factory NutritionGoalException.invalidGoal(String reason) {
    return NutritionGoalException(
      message: 'Invalid nutrition goal: $reason',
      userMessage: reason,
    );
  }
}

/// Exception for barcode scanning operations
class BarcodeScanException extends NutritionException {
  const BarcodeScanException({
    required super.message,
    super.userMessage,
    super.originalError,
    super.stackTrace,
  });

  factory BarcodeScanException.scanFailed(dynamic error, [StackTrace? stackTrace]) {
    return BarcodeScanException(
      message: 'Barcode scan failed: $error',
      userMessage: 'Unable to scan barcode. Please try entering it manually.',
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  factory BarcodeScanException.productNotFound(String barcode) {
    return BarcodeScanException(
      message: 'Product not found for barcode: $barcode',
      userMessage: 'Product not found in database. Try adding it manually.',
    );
  }

  factory BarcodeScanException.networkError(dynamic error, [StackTrace? stackTrace]) {
    return BarcodeScanException(
      message: 'Network error during barcode lookup: $error',
      userMessage: 'Unable to look up product. Please check your internet connection.',
      originalError: error,
      stackTrace: stackTrace,
    );
  }
}

/// Exception for photo-related operations
class NutritionPhotoException extends NutritionException {
  const NutritionPhotoException({
    required super.message,
    super.userMessage,
    super.originalError,
    super.stackTrace,
  });

  factory NutritionPhotoException.uploadFailed(dynamic error, [StackTrace? stackTrace]) {
    return NutritionPhotoException(
      message: 'Photo upload failed: $error',
      userMessage: 'Unable to upload photo. Please try again.',
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  factory NutritionPhotoException.captureFailed(dynamic error, [StackTrace? stackTrace]) {
    return NutritionPhotoException(
      message: 'Photo capture failed: $error',
      userMessage: 'Unable to take photo. Please check camera permissions.',
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  factory NutritionPhotoException.deleteFailed(dynamic error, [StackTrace? stackTrace]) {
    return NutritionPhotoException(
      message: 'Photo deletion failed: $error',
      userMessage: 'Unable to delete photo. Please try again.',
      originalError: error,
      stackTrace: stackTrace,
    );
  }
}

/// Exception for AI nutrition services
class NutritionAIException extends NutritionException {
  const NutritionAIException({
    required super.message,
    super.userMessage,
    super.originalError,
    super.stackTrace,
  });

  factory NutritionAIException.tipGenerationFailed(dynamic error, [StackTrace? stackTrace]) {
    return NutritionAIException(
      message: 'Failed to generate nutrition tips: $error',
      userMessage: 'Unable to generate personalized tips right now. Please try again later.',
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  factory NutritionAIException.chatFailed(dynamic error, [StackTrace? stackTrace]) {
    return NutritionAIException(
      message: 'AI chat failed: $error',
      userMessage: 'Unable to get a response. Please try again.',
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  factory NutritionAIException.recommendationsFailed(dynamic error, [StackTrace? stackTrace]) {
    return NutritionAIException(
      message: 'Meal recommendations failed: $error',
      userMessage: 'Unable to generate meal suggestions. Please try again.',
      originalError: error,
      stackTrace: stackTrace,
    );
  }
}
