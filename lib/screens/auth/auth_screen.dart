import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';
import '../../auth/auth_controller.dart';
import '../../auth/auth_state.dart' as auth_state;

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool isLogin = true;

  final _formKey = GlobalKey<FormState>();

  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _signupEmailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _signupPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _signupEmailController.dispose();
    _phoneController.dispose();
    _signupPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<auth_state.AuthState>(
      authControllerProvider,
      (previous, next) {
        final message = next.errorMessage;
        if (message != null && message.isNotEmpty && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
          ref.read(authControllerProvider.notifier).clearError();
        }
      },
    );

    final auth = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: AppTheme.surfaceWhite,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
            child: Form(
              key: _formKey,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, 0.05),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: isLogin
                    ? _buildSignIn(isLoading: auth.isLoading)
                    : _buildSignUp(isLoading: auth.isLoading),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignIn({required bool isLoading}) {
    return Column(
      key: const ValueKey("SignIn"),
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildLogo(),
        const SizedBox(height: 40),
        const Text(
          "Welcome Back",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: AppTheme.primaryDark,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "Sign in to continue your journey with Parrot.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600, height: 1.5),
        ),
        const SizedBox(height: 48),
        _buildTextField(
          "Email Address",
          LucideIcons.mail,
          controller: _loginEmailController,
          keyboardType: TextInputType.emailAddress,
          validator: _validateEmail,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          "Password",
          LucideIcons.lock,
          controller: _loginPasswordController,
          obscure: true,
          validator: _validatePassword,
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => context.push('/forgot-password'),
            child: const Text("Forgot Password?", style: TextStyle(color: AppTheme.logoSage, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 32),
        _buildPrimaryButton(
          "Sign In",
          isLoading: isLoading,
          onPressed: () async {
            if (!_formKey.currentState!.validate()) return;
            final controller = ref.read(authControllerProvider.notifier);
            final result = await controller.signIn(
              email: _loginEmailController.text.trim(),
              password: _loginPasswordController.text,
            );
            if (!mounted) return;
            if (result.success) {
              context.go('/main');
            }
          },
        ),
        const SizedBox(height: 32),
        _buildToggleRow("New to Parrot? ", "Create Account"),
      ],
    );
  }

  Widget _buildSignUp({required bool isLoading}) {
    return Column(
      key: const ValueKey("SignUp"),
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildLogo(),
        const SizedBox(height: 32),
        const Text(
          "Create Account",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: AppTheme.primaryDark,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Join us and discover your unique voice identity.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600, height: 1.5),
        ),
        const SizedBox(height: 32),
        
        // Extended Fields
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                "First Name",
                LucideIcons.user,
                controller: _firstNameController,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                "Last Name",
                LucideIcons.user,
                controller: _lastNameController,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(
          "Email Address",
          LucideIcons.mail,
          controller: _signupEmailController,
          keyboardType: TextInputType.emailAddress,
          validator: _validateEmail,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          "Phone Number",
          LucideIcons.phone,
          controller: _phoneController,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          "Password",
          LucideIcons.lock,
          controller: _signupPasswordController,
          obscure: true,
          validator: _validatePassword,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          "Confirm Password",
          LucideIcons.checkCircle,
          controller: _confirmPasswordController,
          obscure: true,
          validator: _validateConfirmPassword,
        ),
        
        const SizedBox(height: 32),
        _buildPrimaryButton(
          "Sign Up",
          isLoading: isLoading,
          onPressed: () async {
            if (!_formKey.currentState!.validate()) return;
            final controller = ref.read(authControllerProvider.notifier);
            final result = await controller.signUp(
              email: _signupEmailController.text.trim(),
              password: _signupPasswordController.text,
              firstName: _firstNameController.text.trim(),
              lastName: _lastNameController.text.trim(),
              phone: _phoneController.text.trim(),
            );
            if (!mounted) return;
            if (result.success) {
              context.go('/main');
            }
          },
        ),
        const SizedBox(height: 32),
        _buildToggleRow("Already have an account? ", "Sign In"),
      ],
    );
  }

  Widget _buildLogo() {
    return Center(
      child: Container(
        height: 80,
        width: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppTheme.logoSage.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Image.asset("assets/brand/logo.jpg"),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    IconData icon, {
    TextEditingController? controller,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool obscure = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscure,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: Icon(icon, color: AppTheme.logoSage.withOpacity(0.5), size: 18),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppTheme.logoSage.withOpacity(0.5)),
          ),
        ),
        style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.primaryDark, fontSize: 14),
      ),
    );
  }

  Widget _buildPrimaryButton(
    String text, {
    required bool isLoading,
    required Future<void> Function() onPressed,
  }) {
    return ElevatedButton(
      onPressed: isLoading ? null : () => onPressed(),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryDark,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 8,
        shadowColor: AppTheme.logoSage.withOpacity(0.4),
      ),
      child: isLoading
          ? const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
    );
  }

  Widget _buildToggleRow(String text, String actionText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(text, style: TextStyle(color: Colors.grey.shade600)),
        GestureDetector(
          onTap: () {
            setState(() {
              isLogin = !isLogin;
            });
          },
          child: Text(
            actionText,
            style: const TextStyle(color: AppTheme.logoSage, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Please enter your email address.';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) {
      return 'Please enter your password.';
    }
    if (password.length < 8) {
      return 'Password must be at least 8 characters.';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    final confirm = value ?? '';
    if (confirm.isEmpty) {
      return 'Please confirm your password.';
    }
    if (confirm != _signupPasswordController.text) {
      return 'Passwords do not match.';
    }
    return null;
  }
}
