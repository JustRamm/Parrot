import 'package:supabase_flutter/supabase_flutter.dart' as supa;

class AuthState {
  final bool isLoading;
  final supa.User? user;
  final String? errorMessage;

  const AuthState({
    required this.isLoading,
    this.user,
    this.errorMessage,
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
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: clearUser ? null : (user ?? this.user),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

