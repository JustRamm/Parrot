import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundClean,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: Container(
                  height: 64,
                  width: 64,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 20,
                      )
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset("assets/brand/logo.jpg"),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              Text(
                isLogin ? "Welcome back" : "Create account",
                style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
              ),
              const SizedBox(height: 8),
              Text(
                isLogin 
                  ? "Enter your credentials to access EchoSign." 
                  : "Start your journey to a personalized voice identity.",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 48),
              if (!isLogin) ...[
                _buildTextField("Full Name", LucideIcons.user),
                const SizedBox(height: 20),
              ],
              _buildTextField("Email address", LucideIcons.mail),
              const SizedBox(height: 20),
              _buildTextField("Password", LucideIcons.lock, obscure: true),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => context.go('/main'),
                child: Text(isLogin ? "Sign in" : "Sign up"),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isLogin ? "Don't have an account? " : "Already have an account? ",
                    style: TextStyle(color: AppTheme.primaryDark.withOpacity(0.6)),
                  ),
                  TextButton(
                    onPressed: () => setState(() => isLogin = !isLogin),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      isLogin ? "Sign up" : "Sign in",
                      style: const TextStyle(
                        color: AppTheme.primaryDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, {bool obscure = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryDark,
            ),
          ),
        ),
        TextField(
          obscureText: obscure,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppTheme.primaryDark.withOpacity(0.4), size: 20),
            hintText: "Enter your ${label.toLowerCase()}",
            hintStyle: TextStyle(color: AppTheme.primaryDark.withOpacity(0.2), fontSize: 14),
          ),
        ),
      ],
    );
  }
}
