import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
