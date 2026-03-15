import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme.dart';
import '../screens/auth/auth_screen.dart';
import '../screens/navigation/main_navigation.dart';
import 'auth_controller.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authControllerProvider);

    if (state.isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.surfaceWhite,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state.user == null) {
      return const AuthScreen();
    }

    return const MainNavigationWrapper();
  }
}

