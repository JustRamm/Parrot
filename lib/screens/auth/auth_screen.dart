import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  bool isLogin = true;
  
  // Create a separate GlobalKey for the form if validation is needed later
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceWhite,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 0.05),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ));
              },
              child: isLogin ? _buildSignIn() : _buildSignUp(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignIn() {
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
        _buildTextField("Email Address", LucideIcons.mail),
        const SizedBox(height: 16),
        _buildTextField("Password", LucideIcons.lock, obscure: true),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            child: const Text("Forgot Password?", style: TextStyle(color: AppTheme.logoSage, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 32),
        _buildPrimaryButton("Sign In", () => context.go('/main')),
        const SizedBox(height: 32),
        _buildToggleRow("New to Parrot? ", "Create Account"),
      ],
    );
  }

  Widget _buildSignUp() {
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
            Expanded(child: _buildTextField("First Name", LucideIcons.user)),
            const SizedBox(width: 12),
            Expanded(child: _buildTextField("Last Name", LucideIcons.user)),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField("Email Address", LucideIcons.mail),
        const SizedBox(height: 16),
         _buildTextField("Phone Number", LucideIcons.phone),
        const SizedBox(height: 16),
        _buildTextField("Password", LucideIcons.lock, obscure: true),
        const SizedBox(height: 16),
         _buildTextField("Confirm Password", LucideIcons.checkCircle, obscure: true),
        
        const SizedBox(height: 32),
        _buildPrimaryButton("Sign Up", () => context.go('/main')),
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

  Widget _buildTextField(String label, IconData icon, {bool obscure = false}) {
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
      child: TextField(
        obscureText: obscure,
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

  Widget _buildPrimaryButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryDark,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 8,
        shadowColor: AppTheme.logoSage.withOpacity(0.4),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
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
}
