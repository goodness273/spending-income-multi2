import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Firebase auth user stream provider
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// Current user data provider
final userDataProvider = FutureProvider<UserModel?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.getUserData();
});

// Auth state enum
enum AuthState {
  initial,
  authenticated,
  unauthenticated,
  authenticating,
  error,
}

// Auth state notifier class
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(AuthState.initial);

  // Sign in with email and password
  Future<UserModel?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      state = AuthState.authenticating;
      final user = await _authService.signInWithEmailAndPassword(
        email,
        password,
      );
      state = AuthState.authenticated;
      return user;
    } catch (e) {
      state = AuthState.error;
      rethrow;
    }
  }

  // Register with email and password
  Future<UserModel?> registerWithEmailAndPassword(
    String email,
    String password,
    String? displayName,
  ) async {
    try {
      state = AuthState.authenticating;
      final user = await _authService.registerWithEmailAndPassword(
        email,
        password,
        displayName,
      );
      state = AuthState.authenticated;
      return user;
    } catch (e) {
      state = AuthState.error;
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      state = AuthState.unauthenticated;
    } catch (e) {
      state = AuthState.error;
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _authService.resetPassword(email);
    } catch (e) {
      rethrow;
    }
  }

  // --- Placeholder: Sign in with Google ---
  Future<UserModel?> signInWithGoogle() async {
    try {
      state = AuthState.authenticating;
      print('[AuthNotifier] Attempting Google Sign In...');
      // TODO: Call _authService.signInWithGoogle() when implemented
      // final user = await _authService.signInWithGoogle();
      // Simulating success for now, replace with actual call
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
      // Assume success for UI flow, actual implementation needed
      // If _authService returns a user, set state to authenticated
      // state = AuthState.authenticated;
      // return user; 

      // Simulate failure for now
      throw Exception('Google Sign-In not implemented yet');

    } catch (e) {
      print('[AuthNotifier] Google Sign In Error: $e');
      state = AuthState.error;
      // Consider rethrowing a more specific error or handling it
      rethrow; 
    }
  }

  // --- Placeholder: Sign in with Apple ---
   Future<UserModel?> signInWithApple() async {
    try {
      state = AuthState.authenticating;
       print('[AuthNotifier] Attempting Apple Sign In...');
      // TODO: Call _authService.signInWithApple() when implemented
      // final user = await _authService.signInWithApple();
      // Simulating success for now, replace with actual call
      await Future.delayed(const Duration(seconds: 1));
       // Assume success for UI flow, actual implementation needed
      // if (user != null) {
      //   state = AuthState.authenticated;
      // }
      // return user; 

      // Simulate failure for now
       throw Exception('Apple Sign-In not implemented yet');

    } catch (e) {
       print('[AuthNotifier] Apple Sign In Error: $e');
      state = AuthState.error;
      rethrow;
    }
  }

}

// Auth notifier provider
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});
