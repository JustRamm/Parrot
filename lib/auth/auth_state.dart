import 'package:supabase_flutter/supabase_flutter.dart' as supa;

class AuthState {
  final bool isLoading;
  final supa.User? user;
  final String? errorMessage;
  final bool isPasswordRecovery;

  const AuthState({
    required this.isLoading,
    this.user,
    this.errorMessage,
    this.isPasswordRecovery = false,
  });

  factory AuthState.initial() {
    return const AuthState(isLoading: true);
  }

  AuthState copyWith({
    bool? isLoading,
    supa.User? user,
    bool clearUser = false,
    String? errorMessage,
    bool clearError = false,
    bool? isPasswordRecovery,
    bool clearRecovery = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: clearUser ? null : (user ?? this.user),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isPasswordRecovery: clearRecovery ? false : (isPasswordRecovery ?? this.isPasswordRecovery),
    );
  }
}

