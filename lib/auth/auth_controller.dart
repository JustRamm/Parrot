import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

import '../services/supabase_auth_service.dart';
import 'auth_state.dart';

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);

class AuthController extends Notifier<AuthState> {
  SupabaseAuthService? _authService;
  StreamSubscription<supa.AuthState>? _authSub;

  @override
  AuthState build() {
    _authService = SupabaseAuthService();
    _subscribeToAuthChanges();
    _initialize();

    ref.onDispose(() {
      _authSub?.cancel();
    });

    return AuthState.initial();
  }

  SupabaseAuthService get _service =>
      _authService ?? SupabaseAuthService();

  Future<void> _initialize() async {
    final user = await _service.getCurrentUser();
    state = state.copyWith(
      isLoading: false,
      user: user,
      clearError: true,
    );
  }

  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _service.signIn(email: email, password: password);
    state = state.copyWith(
      isLoading: false,
      user: result.success ? result.user : state.user,
      errorMessage: result.success ? null : result.message,
      clearError: result.success,
    );
    return result;
  }

  Future<AuthResult> signUp({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? phone,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _service.signUp(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
    );
    state = state.copyWith(
      isLoading: false,
      errorMessage: result.success ? null : result.message,
      clearError: result.success,
    );
    return result;
  }

  Future<AuthResult> signOut() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _service.signOut();
    state = state.copyWith(
      isLoading: false,
      clearUser: result.success,
      errorMessage: result.success ? null : result.message,
      clearError: result.success,
    );
    return result;
  }

  Future<AuthResult> sendPasswordResetEmail(String email) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _service.sendPasswordResetEmail(email);
    state = state.copyWith(
      isLoading: false,
      errorMessage: result.success ? null : result.message,
      clearError: result.success,
    );
    return result;
  }

  Future<AuthResult> changePassword({
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _service.changePassword(newPassword: newPassword);
    state = state.copyWith(
      isLoading: false,
      errorMessage: result.success ? null : result.message,
      clearError: result.success,
    );
    return result;
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void _subscribeToAuthChanges() {
    _authSub = _service.authStateChanges().listen((authState) {
      final user = authState.session?.user;
      final isRecovery = authState.event == supa.AuthChangeEvent.passwordRecovery;
      
      state = state.copyWith(
        user: user,
        clearError: true,
        isPasswordRecovery: isRecovery || state.isPasswordRecovery, // keep it true if it was true
      );
    });
  }

  void clearPasswordRecovery() {
    state = state.copyWith(clearRecovery: true);
  }
}

