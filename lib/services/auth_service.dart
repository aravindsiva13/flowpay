import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../services/mock_data.dart';
import '../services/storage_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StorageService _storage = StorageService();
  
  // For development - toggle between mock and real Firebase
  static const bool useMockAuth = true;

  // Get current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign in with email and password
  Future<UserModel?> signInWithEmailAndPassword(String email, String password) async {
    if (useMockAuth) {
      return _mockSignIn(email, password);
    }

    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (result.user != null) {
        final userModel = await _getUserModel(result.user!.uid);
        await _storage.saveUserData(userModel);
        return userModel;
      }
      return null;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Sign up with email and password
  Future<UserModel?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    UserRole role = UserRole.employee,
  }) async {
    if (useMockAuth) {
      return _mockSignUp(email: email, password: password, name: name, role: role);
    }

    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (result.user != null) {
        // Update display name
        await result.user!.updateDisplayName(name);

        // Create user document in Firestore
        final userModel = UserModel(
          id: result.user!.uid,
          email: email.trim(),
          name: name,
          role: role,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _firestore.collection('users').doc(result.user!.uid).set(userModel.toJson());
        await _storage.saveUserData(userModel);
        return userModel;
      }
      return null;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    if (useMockAuth) {
      await _storage.clearUserData();
      return;
    }

    try {
      await _auth.signOut();
      await _storage.clearUserData();
    } catch (e) {
      throw Exception('Failed to sign out: ${e.toString()}');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    if (useMockAuth) {
      // Mock implementation - in real app would send reset email
      throw Exception('Password reset email sent to $email');
    }

    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Get current user model
  Future<UserModel?> getCurrentUserModel() async {
    if (useMockAuth) {
      return await _storage.getUserData();
    }

    try {
      final user = _auth.currentUser;
      if (user != null) {
        return await _getUserModel(user.uid);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Get user role
  Future<String> getUserRole() async {
    try {
      final userModel = await getCurrentUserModel();
      return userModel?.role.name ?? 'employee';
    } catch (e) {
      return 'employee';
    }
  }

  // Update user profile
  Future<void> updateUserProfile({String? name, String? email}) async {
    if (useMockAuth) {
      final currentUser = await _storage.getUserData();
      if (currentUser != null) {
        final updatedUser = currentUser.copyWith(
          name: name ?? currentUser.name,
          email: email ?? currentUser.email,
          updatedAt: DateTime.now(),
        );
        await _storage.saveUserData(updatedUser);
      }
      return;
    }

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Update Firebase Auth profile
      if (name != null) {
        await user.updateDisplayName(name);
      }
      if (email != null) {
        await user.updateEmail(email);
      }

      // Update Firestore document
      final updates = <String, dynamic>{
        'updatedAt': Timestamp.now(),
      };
      if (name != null) updates['name'] = name;
      if (email != null) updates['email'] = email;

      await _firestore.collection('users').doc(user.uid).update(updates);

      // Update local storage
      final userModel = await _getUserModel(user.uid);
      if (userModel != null) {
        await _storage.saveUserData(userModel);
      }
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Change password
  Future<void> changePassword(String currentPassword, String newPassword) async {
    if (useMockAuth) {
      // Mock implementation
      if (currentPassword.isEmpty || newPassword.isEmpty) {
        throw Exception('Passwords cannot be empty');
      }
      return;
    }

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      
      await user.reauthenticateWithCredential(credential);
      
      // Update password
      await user.updatePassword(newPassword);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Check if user is admin
  Future<bool> isAdmin() async {
    try {
      final role = await getUserRole();
      return role == 'admin';
    } catch (e) {
      return false;
    }
  }

  // Check if user is employee
  Future<bool> isEmployee() async {
    try {
      final role = await getUserRole();
      return role == 'employee';
    } catch (e) {
      return true; // Default to employee
    }
  }

  // Verify email
  Future<void> sendEmailVerification() async {
    if (useMockAuth) return;

    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Check if email is verified
  bool get isEmailVerified {
    if (useMockAuth) return true;
    return _auth.currentUser?.emailVerified ?? false;
  }

  // Reload user data
  Future<void> reloadUser() async {
    if (useMockAuth) return;

    try {
      await _auth.currentUser?.reload();
    } catch (e) {
      // Ignore errors
    }
  }

  // Delete user account
  Future<void> deleteAccount(String password) async {
    if (useMockAuth) {
      await _storage.clearUserData();
      return;
    }

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      
      await user.reauthenticateWithCredential(credential);
      
      // Delete Firestore document
      await _firestore.collection('users').doc(user.uid).delete();
      
      // Delete Firebase Auth account
      await user.delete();
      
      // Clear local storage
      await _storage.clearUserData();
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Private methods

  // Get user model from Firestore
  Future<UserModel?> _getUserModel(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromJson({...doc.data()!, 'id': doc.id});
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Handle authentication errors
  Exception _handleAuthError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return Exception('No user found for that email address');
        case 'wrong-password':
          return Exception('Invalid password');
        case 'invalid-email':
          return Exception('Invalid email address');
        case 'user-disabled':
          return Exception('This user account has been disabled');
        case 'too-many-requests':
          return Exception('Too many failed attempts. Please try again later');
        case 'email-already-in-use':
          return Exception('An account already exists for that email address');
        case 'weak-password':
          return Exception('Password is too weak');
        case 'network-request-failed':
          return Exception('Network error. Please check your connection');
        case 'requires-recent-login':
          return Exception('Please sign in again to complete this action');
        default:
          return Exception('Authentication failed: ${error.message}');
      }
    } else if (error is FirebaseException) {
      return Exception('Database error: ${error.message}');
    } else {
      return Exception('An unexpected error occurred: ${error.toString()}');
    }
  }

  // Mock authentication methods for development

  Future<UserModel?> _mockSignIn(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 1000)); // Simulate network delay

    // Get mock user by email
    final user = MockDataService.getUserByEmail(email);
    if (user == null) {
      throw Exception('No user found for that email address');
    }

    // In real app, password would be validated
    if (password.isEmpty) {
      throw Exception('Password is required');
    }

    // Save to local storage
    await _storage.saveUserData(user);
    return user;
  }

  Future<UserModel?> _mockSignUp({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1200)); // Simulate network delay

    // Check if user already exists
    final existingUser = MockDataService.getUserByEmail(email);
    if (existingUser != null) {
      throw Exception('An account already exists for that email address');
    }

    // Create new user
    final newUser = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      name: name,
      role: role,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Save to local storage
    await _storage.saveUserData(newUser);
    return newUser;
  }

  // Check authentication state
  Future<bool> isAuthenticated() async {
    if (useMockAuth) {
      final userData = await _storage.getUserData();
      return userData != null;
    }

    return _auth.currentUser != null;
  }

  // Get user display name
  String get displayName {
    if (useMockAuth) {
      // Would get from local storage in real implementation
      return 'Mock User';
    }
    return _auth.currentUser?.displayName ?? 'User';
  }

  // Get user email
  String get email {
    if (useMockAuth) {
      // Would get from local storage in real implementation
      return 'mock@example.com';
    }
    return _auth.currentUser?.email ?? '';
  }

  // Get user ID
  String get uid {
    if (useMockAuth) {
      // Would get from local storage in real implementation
      return 'mock_uid';
    }
    return _auth.currentUser?.uid ?? '';
  }
}