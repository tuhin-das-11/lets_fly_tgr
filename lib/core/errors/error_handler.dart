import 'dart:developer' as developer;
import 'app_exception.dart';

/// Global error handling and error translation logic.
abstract class ErrorHandler {
  static String getDisplayMessage(dynamic error) {
    if (error is AppException) {
      return error.message;
    }
    
    final errorString = error.toString().toLowerCase();
    if (errorString.contains('socketexception') || errorString.contains('network')) {
      return 'Network connection error. Operating in offline mode.';
    }
    if (errorString.contains('invalid login credentials')) {
      return 'Invalid email or password. Please verify and retry.';
    }
    if (errorString.contains('user already registered')) {
      return 'An account already exists with this email.';
    }

    developer.log('Unhandled error caught: $error', name: 'ErrorHandler');
    return 'An unexpected error occurred. Please try again later.';
  }
}
