import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';

class AccountDeletionScreen extends StatefulWidget {
  const AccountDeletionScreen({super.key});

  @override
  State<AccountDeletionScreen> createState() => _AccountDeletionScreenState();
}

class _AccountDeletionScreenState extends State<AccountDeletionScreen> {
  int _step = 0;
  bool _consentChecked = false;
  bool _isLoading = false;
  final _passwordController = TextEditingController();
  bool _showPassword = false;

  final List<String> _consequences = [
    'Your voice profiles and clones will be permanently deleted.',
    'All translation history will be erased and unrecoverable.',
    'Your Pro subscription will be cancelled immediately without refund.',
    'Your account credentials and personal data will be removed.',
    'You will lose access to the Parrot app and all its features.',
  ];

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _deleteAccount() async {
    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your password to confirm.')),
      );
      return;
    }
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    setState(() => _isLoading = false);

    // Show final goodbye dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(LucideIcons.userX, size: 48, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 24),
              const Text('Account Deleted',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.primaryDark)),
              const SizedBox(height: 12),
              Text(
                'Your account has been permanently deleted. We\'re sorry to see you go.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.5),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go('/onboarding');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryDark,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                ),
                child: const Text('Back to Start', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () {
            if (_step > 0) {
              setState(() => _step--);
            } else {
              context.pop();
            }
          },
        ),
        title: const Text('Delete Account',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: _step == 0 ? _buildWarningStep() : _buildConfirmStep(),
        ),
      ),
    );
  }

  Widget _buildWarningStep() {
    return Column(
      key: const ValueKey('warning'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Warning banner
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.logoBerry.withOpacity(0.06),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.logoBerry.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.logoBerry.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(LucideIcons.alertTriangle, color: AppTheme.logoBerry, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'This action is irreversible',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.logoBerry),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Once deleted, your account cannot be recovered.',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        const Text('What you will lose:',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.primaryDark)),
        const SizedBox(height: 16),

        ..._consequences.map(
          (c) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppTheme.logoBerry,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.x, size: 10, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(c,
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.4)),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 32),

        // Consent checkbox
        GestureDetector(
          onTap: () => setState(() => _consentChecked = !_consentChecked),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _consentChecked
                  ? AppTheme.logoBerry.withOpacity(0.06)
                  : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _consentChecked ? AppTheme.logoBerry : Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: _consentChecked ? AppTheme.logoBerry : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: _consentChecked ? AppTheme.logoBerry : Colors.grey.shade400,
                    ),
                  ),
                  child: _consentChecked
                      ? const Icon(LucideIcons.check, size: 14, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'I understand that deleting my account is permanent and cannot be undone.',
                    style: TextStyle(
                      fontSize: 13,
                      color: _consentChecked ? AppTheme.logoBerry : Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),

        ElevatedButton(
          onPressed: _consentChecked ? () => setState(() => _step = 1) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.logoBerry,
            disabledBackgroundColor: Colors.grey.shade200,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text(
            'Continue',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => context.pop(),
          child: Text('Cancel, keep my account',
              style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildConfirmStep() {
    return Column(
      key: const ValueKey('confirm'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        const Text(
          'Confirm Your Identity',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.primaryDark),
        ),
        const SizedBox(height: 12),
        Text(
          'Enter your account password to permanently delete your account.',
          style: TextStyle(fontSize: 15, color: Colors.grey.shade600, height: 1.5),
        ),
        const SizedBox(height: 36),

        // Password field
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _passwordController,
            obscureText: !_showPassword,
            decoration: InputDecoration(
              labelText: 'Password',
              labelStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon: Icon(LucideIcons.lock, color: Colors.grey.shade400, size: 18),
              suffixIcon: IconButton(
                icon: Icon(_showPassword ? LucideIcons.eyeOff : LucideIcons.eye,
                    color: Colors.grey.shade400, size: 18),
                onPressed: () => setState(() => _showPassword = !_showPassword),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.transparent),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppTheme.logoBerry.withOpacity(0.5)),
              ),
            ),
            style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.primaryDark, fontSize: 14),
          ),
        ),
        const SizedBox(height: 48),

        ElevatedButton(
          onPressed: _isLoading ? null : _deleteAccount,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.logoBerry,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: _isLoading
              ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Text('Deleting Account...',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                )
              : const Text(
                  'Yes, Delete My Account',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => setState(() => _step = 0),
          child: Text('Go Back',
              style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}
