import 'package:supabase_flutter/supabase_flutter.dart' as supa;

class AuthResult {
  final bool success;
  final String? message;
  final supa.User? user;

  const AuthResult({
    required this.success,
    this.message,
    this.user,
  });

  factory AuthResult.success(supa.User? user) {
    return AuthResult(success: true, user: user);
  }

  factory AuthResult.failure(String message) {
    return AuthResult(success: false, message: message);
  }
}

class SupabaseAuthService {
  SupabaseAuthService({supa.SupabaseClient? client})
      : _client = client ?? supa.Supabase.instance.client;

  final supa.SupabaseClient _client;

  Future<AuthResult> signUp({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? phone,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: <String, dynamic>{
          if (firstName != null && firstName.isNotEmpty) 'first_name': firstName,
          if (lastName != null && lastName.isNotEmpty) 'last_name': lastName,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
        },
      );
      return AuthResult.success(response.user);
    } on supa.AuthException catch (e) {
      return AuthResult.failure(_mapAuthException(e));
    } catch (_) {
      return AuthResult.failure('Something went wrong. Please try again.');
    }
  }

  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return AuthResult.success(response.user);
    } on supa.AuthException catch (e) {
      return AuthResult.failure(_mapAuthException(e));
    } catch (_) {
      return AuthResult.failure('Something went wrong. Please try again.');
    }
  }

  Future<AuthResult> signOut() async {
    try {
      await _client.auth.signOut();
      return const AuthResult(success: true);
    } on supa.AuthException catch (e) {
      return AuthResult.failure(_mapAuthException(e));
    } catch (_) {
      return AuthResult.failure('Unable to sign out. Please try again.');
    }
  }

  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
      return const AuthResult(success: true);
    } on supa.AuthException catch (e) {
      return AuthResult.failure(_mapAuthException(e));
    } catch (_) {
      return AuthResult.failure('Unable to send reset email. Please try again.');
    }
  }

  Future<AuthResult> changePassword({
    required String newPassword,
  }) async {
    try {
      await _client.auth.updateUser(
        supa.UserAttributes(password: newPassword),
      );
      return const AuthResult(success: true);
    } on supa.AuthException catch (e) {
      return AuthResult.failure(_mapAuthException(e));
    } catch (_) {
      return AuthResult.failure('Unable to update password. Please try again.');
    }
  }

  Future<supa.User?> getCurrentUser() async {
    return _client.auth.currentUser;
  }

  Stream<supa.AuthState> authStateChanges() {
    return _client.auth.onAuthStateChange;
  }

  String _mapAuthException(supa.AuthException exception) {
    final message = exception.message.toLowerCase();

    if (message.contains('invalid login credentials')) {
      return 'Invalid email or password.';
    }
    if (message.contains('user already registered') ||
        message.contains('already registered')) {
      return 'An account with this email already exists.';
    }
    if (message.contains('email not confirmed')) {
      return 'Please confirm your email before signing in.';
    }

    return exception.message;
  }
}

