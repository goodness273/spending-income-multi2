import 'package:firebase_auth/firebase_auth.dart';

class AuthErrorHandler {
  /// Converts Firebase Auth error codes to user-friendly error messages
  static String handleError(dynamic error) {
    String errorMessage = 'An unknown error occurred';

    if (error is FirebaseAuthException) {
      switch (error.code) {
        // Registration errors
        case 'email-already-in-use':
          errorMessage =
              'This email is already registered. Please use a different email or login.';
          break;
        case 'invalid-email':
          errorMessage =
              'The email address is not valid. Please enter a valid email.';
          break;
        case 'weak-password':
          errorMessage =
              'Your password is too weak. Please use a stronger password.';
          break;
        case 'operation-not-allowed':
          errorMessage =
              'This type of account is not enabled. Please contact support.';
          break;

        // Login errors
        case 'user-disabled':
          errorMessage =
              'This account has been disabled. Please contact support.';
          break;
        case 'user-not-found':
          errorMessage =
              'No account found with this email. Please check your email or sign up.';
          break;
        case 'wrong-password':
          errorMessage =
              'Incorrect password. Please check your password and try again.';
          break;
        case 'invalid-credential':
          errorMessage = 'The login credentials are invalid. Please try again.';
          break;

        // Password reset errors
        case 'missing-email':
          errorMessage = 'Please enter your email address.';
          break;

        // General errors
        case 'network-request-failed':
          errorMessage =
              'Network error. Please check your internet connection and try again.';
          break;
        case 'too-many-requests':
          errorMessage =
              'Too many unsuccessful attempts. Please try again later.';
          break;
        default:
          // If we have a message from Firebase, use it
          errorMessage =
              error.message ?? 'Authentication failed. Please try again.';
      }
    } else if (error is Exception) {
      // Handle other exceptions
      errorMessage = error.toString().replaceAll('Exception: ', '');
    }

    return errorMessage;
  }
}
