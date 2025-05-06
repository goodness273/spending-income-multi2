import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:logger/logger.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final Logger _logger = Logger();

  // Get the current user
  User? get currentUser => _auth.currentUser;

  // Stream to listen to authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Register with email & password
  Future<UserModel> registerWithEmailAndPassword(
    String email,
    String password,
    String? displayName,
  ) async {
    try {
      // Create user with email and password
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        // Create a new user document in Firestore
        UserModel userModel = UserModel(
          id: user.uid,
          email: email,
          displayName: displayName,
        );

        // Add user data to Firestore
        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(userModel.toMap());

        return userModel;
      } else {
        throw Exception('Failed to create user');
      }
    } catch (e) {
      rethrow; // Re-throw the exception for handling in UI
    }
  }

  // Sign in with email & password
  Future<UserModel> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        // Get user data from Firestore
        DocumentSnapshot doc =
            await _firestore.collection('users').doc(user.uid).get();

        if (doc.exists) {
          return UserModel.fromFirestore(doc);
        } else {
          // If user exists in Auth but not in Firestore, create the document
          UserModel userModel = UserModel(id: user.uid, email: email);

          await _firestore
              .collection('users')
              .doc(user.uid)
              .set(userModel.toMap());

          return userModel;
        }
      } else {
        throw Exception('Failed to sign in');
      }
    } catch (e) {
      rethrow; // Re-throw the exception for handling in UI
    }
  }

  // Sign out
  Future<void> signOut() async {
    return await _auth.signOut();
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    return await _auth.sendPasswordResetEmail(email: email);
  }

  // --- Sign in with Google ---
  Future<UserModel> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // Obtain the auth details from the request
      if (googleUser == null) {
        // User cancelled the sign-in
        throw FirebaseAuthException(
          code: 'USER_CANCELLED',
          message: 'Google Sign-In was cancelled by the user.',
        );
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      UserCredential result = await _auth.signInWithCredential(credential);
      User? user = result.user;

      if (user != null) {
        // Check if user exists in Firestore, otherwise create
        DocumentSnapshot doc =
            await _firestore.collection('users').doc(user.uid).get();

        if (doc.exists) {
          return UserModel.fromFirestore(doc);
        } else {
          // Create a new user document in Firestore
          UserModel userModel = UserModel(
            id: user.uid,
            email: user.email ?? '', // Google provides email
            displayName: user.displayName, // Google provides display name
            // You might want to store the photoURL as well: user.photoURL
          );
          await _firestore
              .collection('users')
              .doc(user.uid)
              .set(userModel.toMap());
          return userModel;
        }
      } else {
        throw Exception('Failed to sign in with Google');
      }
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase Auth errors
      _logger.e("Firebase Auth Error during Google Sign In: ${e.code} - ${e.message}");
      rethrow;
    } catch (e) {
      _logger.e("General Error during Google Sign In: $e");
      // Handle other errors (network issues, etc.)
      rethrow;
    }
  }

  // --- Sign in with Apple ---
  Future<UserModel> signInWithApple() async {
    try {
       // Note: This requires additional platform setup (Xcode, Apple Dev Portal)
       // It will likely only work on real iOS/macOS devices or simulators.
      final AuthorizationCredentialAppleID appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
         // Add nonce for web if needed, requires crypto package
        // webAuthenticationOptions: WebAuthenticationOptions(
        //   clientId: 'YOUR_CLIENT_ID', // Your service ID from Apple Dev Portal
        //   redirectUri: Uri.parse('YOUR_REDIRECT_URI'), // Configured in Firebase/Apple
        // ),
        // nonce: kIsWeb ? _createNonce() : null, // Nonce for web replay protection
      );

      final OAuthCredential credential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode, // Or identityToken, check docs
        // rawNonce: kIsWeb ? _createNonce() : null, // If using nonce
      );

       // Sign in to Firebase with the credential
      UserCredential result = await _auth.signInWithCredential(credential);
       User? user = result.user;

      if (user != null) {
         // Check if user exists in Firestore, otherwise create
        DocumentSnapshot doc =
            await _firestore.collection('users').doc(user.uid).get();

        if (doc.exists) {
          return UserModel.fromFirestore(doc);
        } else {
          // Create a new user document in Firestore
          // Apple only provides name/email on first sign-up
          UserModel userModel = UserModel(
            id: user.uid,
            email: appleCredential.email ?? user.email ?? '', // Prioritize Apple provided email
            displayName: appleCredential.givenName != null
              ? '${appleCredential.givenName} ${appleCredential.familyName ?? ''}'.trim()
              : user.displayName,
             // You might want to store the photoURL as well: user.photoURL (often null for Apple)
          );
           await _firestore
              .collection('users')
              .doc(user.uid)
              .set(userModel.toMap());
          return userModel;
        }
      } else {
         throw Exception('Failed to sign in with Apple');
      }
    } on FirebaseAuthException catch (e) {
       _logger.e("Firebase Auth Error during Apple Sign In: ${e.code} - ${e.message}");
      rethrow;
    } catch (e) {
       _logger.e("General Error during Apple Sign In: $e");
       // Handle specific Apple Sign In errors if needed
      rethrow;
    }
  }

  // Helper for creating nonce (example, requires crypto package)
  // String _createNonce() {
  //   final random = Random.secure();
  //   return base64Url.encode(List<int>.generate(16, (_) => random.nextInt(256)));
  // }

  // Get user data from Firestore
  Future<UserModel?> getUserData() async {
    try {
      User? user = currentUser;

      if (user != null) {
        DocumentSnapshot doc =
            await _firestore.collection('users').doc(user.uid).get();

        if (doc.exists) {
          return UserModel.fromFirestore(doc);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? displayName,
    List<String>? categories,
  }) async {
    try {
      User? user = currentUser;

      if (user != null) {
        Map<String, dynamic> updateData = {};

        if (displayName != null) {
          updateData['displayName'] = displayName;
        }

        if (categories != null) {
          updateData['categories'] = categories;
        }

        if (updateData.isNotEmpty) {
          await _firestore.collection('users').doc(user.uid).update(updateData);
        }
      }
    } catch (e) {
      rethrow;
    }
  }
}
