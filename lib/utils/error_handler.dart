import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// A utility class for handling errors and logging throughout the app.
/// This class provides methods for displaying error messages to users,
/// logging errors for debugging, and handling different types of errors.
class ErrorHandler {
  // Singleton pattern
  static final ErrorHandler _instance = ErrorHandler._internal();
  factory ErrorHandler() => _instance;
  ErrorHandler._internal();

  // Log levels
  static const int info = 0;
  static const int warning = 1;
  static const int error = 2;
  static const int critical = 3;

  // In-memory log for debugging
  final List<Map<String, dynamic>> _logs = [];
  List<Map<String, dynamic>> get logs => _logs;

  /// Log a message with specified level
  void log(String message, {int level = info, dynamic errors, StackTrace? stackTrace}) {
    final timestamp = DateTime.now();
    final logEntry = {
      'timestamp': timestamp,
      'level': level,
      'message': message,
      'error': errors?.toString(),
      'stackTrace': stackTrace?.toString(),
    };

    // Add to in-memory log
    _logs.add(logEntry);

    // Print to console with appropriate formatting
    String levelString;
    switch (level) {
      case info:
        levelString = '💡 INFO';
        break;
      case warning:
        levelString = '⚠️ WARNING';
        break;
      case error:
        levelString = '❌ ERROR';
        break;
      case critical:
        levelString = '🔥 CRITICAL';
        break;
      default:
        levelString = '💡 INFO';
    }

    Get.snackbar('$levelString [${timestamp.toIso8601String()}]', message);
    if (errors != null) {
      Get.snackbar('Error details', errors);
    }
    if (stackTrace != null) {
      Get.snackbar('Stack trace', stackTrace.toString());
    }

    // For critical errors, we might want to send to a remote logging service
    if (level == critical) {
      // TODO: Implement remote logging for critical errors
    }
  }

  /// Show a snackbar with an error message
  void showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      icon: const Icon(Icons.error, color: Colors.white),
      duration: const Duration(seconds: 3),
    );

    // Also log the error
    log(message, level: error, errors: title);
  }

  /// Show a snackbar with a success message
  void showSuccessSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle, color: Colors.white),
      duration: const Duration(seconds: 2),
    );

    // Also log the success
    log(message, level: info);
  }

  /// Show a snackbar with a warning message
  void showWarningSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      icon: const Icon(Icons.warning, color: Colors.white),
      duration: const Duration(seconds: 3),
    );

    // Also log the warning
    log(message, level: warning);
  }

  /// Handle database errors
  void handleDatabaseError(dynamic error, {String customMessage = ''}) {
    final message = customMessage.isNotEmpty ? customMessage : 'A database error occurred. Please try again.';

    showErrorSnackbar('Database Error', message);
    log('Database error: $error', level: error, errors: error);
  }

  /// Handle network errors
  void handleNetworkError(dynamic error, {String customMessage = ''}) {
    final message = customMessage.isNotEmpty
        ? customMessage
        : 'A network error occurred. Please check your connection and try again.';

    showErrorSnackbar('Network Error', message);
    log('Network error: $error', level: error, errors: error);
  }

  /// Handle validation errors
  void handleValidationError(String field, String message) {
    showWarningSnackbar('Validation Error', '$field: $message');
    log('Validation error: $field - $message', level: warning);
  }

  /// Clear logs (for testing or memory management)
  void clearLogs() {
    _logs.clear();
  }

  /// Export logs as a string (for debugging or sending reports)
  String exportLogs() {
    final buffer = StringBuffer();
    for (final log in _logs) {
      buffer.writeln('${log['timestamp']} [${_getLevelName(log['level'])}] ${log['message']}');
      if (log['error'] != null) {
        buffer.writeln('Error: ${log['error']}');
      }
      if (log['stackTrace'] != null) {
        buffer.writeln('Stack trace: ${log['stackTrace']}');
      }
      buffer.writeln('---');
    }
    return buffer.toString();
  }

  /// Get the string representation of a log level
  String _getLevelName(int level) {
    switch (level) {
      case info:
        return 'INFO';
      case warning:
        return 'WARNING';
      case error:
        return 'ERROR';
      case critical:
        return 'CRITICAL';
      default:
        return 'UNKNOWN';
    }
  }
}
