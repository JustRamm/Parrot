import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/onboarding/app_onboarding.dart';
import '../screens/auth/auth_screen.dart';
import '../screens/navigation/main_navigation.dart';
import '../screens/voice_studio/voice_library.dart';
import '../screens/onboarding/voice_creation_wizard.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const AppOnboardingScreen(),
    ),
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: '/main',
      builder: (context, state) => const MainNavigationWrapper(),
    ),
    GoRoute(
      path: '/voice-library',
      builder: (context, state) => const VoiceLibraryScreen(),
    ),
    GoRoute(
      path: '/voice-wizard',
      builder: (context, state) => const VoiceCreationWizard(),
    ),
  ],
);
