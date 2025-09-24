import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// Auth state provider
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.read(authServiceProvider);
  return authService.authStateChanges;
});

// Current user model provider
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final authService = ref.read(authServiceProvider);
  return await authService.getCurrentUserModel();
});

// Auth provider for managing authentication state
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.read(authServiceProvider);
  return AuthNotifier(authService);
});

// Auth state model
class AuthState {
  final bool isLoading;
  final UserModel? user;
  final String? error;
  final bool isSignedIn;

  const AuthState({
    this.isLoading = false,
    this.user,
    this.error,
    this.isSignedIn = false,
  });

  AuthState copyWith({
    bool? isLoading,
    UserModel? user,
    String? error,
    bool? isSignedIn,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error,
      isSignedIn: isSignedIn ?? this.isSignedIn,
    );
  }
}

// Auth state notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AuthState()) {
    _initialize();
  }

  void _initialize() async {
    state = state.copyWith(isLoading: true);
    try {
      final user = await _authService.getCurrentUserModel();
      state = state.copyWith(
        isLoading: false,
        user: user,
        isSignedIn: user != null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Sign in
  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authService.signInWithEmailAndPassword(email, password);
      state = state.copyWith(
        isLoading: false,
        user: user,
        isSignedIn: user != null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Sign up
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    UserRole role = UserRole.employee,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
        role: role,
      );
      state = state.copyWith(
        isLoading: false,
        user: user,
        isSignedIn: user != null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    try {
      await _authService.signOut();
      state = state.copyWith(
        isLoading: false,
        user: null,
        isSignedIn: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
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

  // Get user role
  Future<String> getUserRole() async {
    try {
      return await _authService.getUserRole();
    } catch (e) {
      return 'employee';
    }
  }

  // Update profile
  Future<void> updateProfile({
    String? name,
    String? email,
  }) async {
    try {
      await _authService.updateUserProfile(name: name, email: email);
      
      // Update local state
      if (state.user != null) {
        final updatedUser = state.user!.copyWith(
          name: name ?? state.user!.name,
          email: email ?? state.user!.email,
          updatedAt: DateTime.now(),
        );
        state = state.copyWith(user: updatedUser);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Change password
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      await _authService.changePassword(currentPassword, newPassword);
    } catch (e) {
      rethrow;
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}