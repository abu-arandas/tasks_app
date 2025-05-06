import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:developer' as developer;

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

  /// Get device information for remote logging
  Future<Map<String, dynamic>> _getDeviceInfo() async {
    // Basic device info that doesn't require additional packages
    return {
      'os': Platform.operatingSystem,
      'osVersion': Platform.operatingSystemVersion,
      'dartVersion': Platform.version,
      'locale': Platform.localeName,
      'numberOfProcessors': Platform.numberOfProcessors,
    };
  }

  List<Map<String, dynamic>> get logs => _logs;

  /// Log a message with specified level
  void log(String message, {int level = info, dynamic errors, StackTrace? stackTrace, bool showSnackbar = false}) {
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

    // Get level string for logging
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

    // Log to console using developer.log
    developer.log(message, name: 'ErrorHandler:${_getLevelName(level)}', error: errors, stackTrace: stackTrace);

    // Only show snackbar if explicitly requested
    if (showSnackbar) {
      Get.snackbar('$levelString [${timestamp.toIso8601String()}]', message);
      if (errors != null) {
        Get.snackbar('Error details', errors.toString());
      }
      if (stackTrace != null) {
        Get.snackbar('Stack trace', stackTrace.toString());
      }
    }

    // For critical errors, we send to a remote logging service
    if (level == critical) {
      _sendToRemoteLoggingService(message, errors, stackTrace);
    }
  }

  /// Send error logs to a remote logging service
  Future<void> _sendToRemoteLoggingService(String message, dynamic errors, StackTrace? stackTrace) async {
    try {
      // Format the error data for remote logging
      final Map<String, dynamic> errorData = {
        'timestamp': DateTime.now().toIso8601String(),
        'message': message,
        'error': errors.toString(),
        'stackTrace': stackTrace?.toString() ?? 'No stack trace available',
        'appVersion': '1.0.0', // This should be dynamically fetched in a real app
        'platform': Platform.operatingSystem,
        'deviceInfo': await _getDeviceInfo(),
      };

      // In a real app, you would send this data to your logging service
      // For example, using Firebase Crashlytics, Sentry, or a custom API
      developer.log('REMOTE LOG: ${jsonEncode(errorData)}', name: 'ErrorHandler');

      // This is a placeholder for the actual API call
      // await http.post(
      //   Uri.parse('https://your-logging-service.com/api/logs'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: jsonEncode(errorData),
      // );
    } catch (e) {
      // If remote logging fails, log locally as a fallback
      // Use developer.log directly to avoid potential recursive calls
      developer.log('Failed to send error to remote logging service: $e', 
          name: 'ErrorHandler:ERROR', 
          error: e);
      
      // Add to in-memory log manually to avoid recursive call to log()
      _logs.add({
        'timestamp': DateTime.now(),
        'level': error,
        'message': 'Failed to send error to remote logging service: $e',
        'error': e.toString(),
      });
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

    // Also log the error (no need for additional snackbar from log method)
    log(message, level: error, errors: title, showSnackbar: false);
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

    // Also log the success (no need for additional snackbar from log method)
    log(message, level: info, showSnackbar: false);
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

    // Also log the warning (no need for additional snackbar from log method)
    log(message, level: warning, showSnackbar: false);
  }

  /// Handle database errors
  void handleDatabaseError(dynamic error, {String customMessage = ''}) {
    final message = customMessage.isNotEmpty ? customMessage : 'A database error occurred. Please try again.';

    showErrorSnackbar('Database Error', message);
    log('Database error: $error', level: error, errors: error, showSnackbar: false);
  }

  /// Handle network errors
  void handleNetworkError(dynamic error, {String customMessage = ''}) {
    final message = customMessage.isNotEmpty
        ? customMessage
        : 'A network error occurred. Please check your connection and try again.';

    showErrorSnackbar('Network Error', message);
    log('Network error: $error', level: error, errors: error, showSnackbar: false);
  }

  /// Handle validation errors
  void handleValidationError(String field, String message) {
    showWarningSnackbar('Validation Error', '$field: $message');
    log('Validation error: $field - $message', level: warning, showSnackbar: false);
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
