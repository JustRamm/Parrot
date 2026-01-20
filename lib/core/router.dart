import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/onboarding/app_onboarding.dart';
import '../screens/auth/auth_screen.dart';
import '../screens/navigation/main_navigation.dart';
import '../screens/voice_studio/voice_library.dart';
import '../screens/onboarding/voice_creation_wizard.dart';
import '../screens/learning/gesture_library.dart';
import '../screens/history/history_screen.dart';
import '../screens/settings/account_settings.dart';
import '../screens/settings/language_settings.dart';
import '../screens/settings/accessibility_settings.dart';
import '../screens/settings/privacy_settings.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/learning/gesture_detail_screen.dart';
import '../screens/settings/help_support_screen.dart';
import '../screens/settings/subscription_screen.dart';
import '../screens/learning/practice_mode.dart';

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
    GoRoute(
      path: '/learning',
      builder: (context, state) => const GestureLibraryScreen(),
    ),
    GoRoute(
      path: '/practice',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return PracticeModeScreen(gestureName: data['gestureName']);
      },
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const HistoryScreen(),
    ),
    GoRoute(
      path: '/account-settings',
      builder: (context, state) => const AccountSettingsScreen(),
    ),
    GoRoute(
      path: '/settings/language',
      builder: (context, state) => const LanguageSettingsScreen(),
    ),
    GoRoute(
      path: '/settings/accessibility',
      builder: (context, state) => const AccessibilitySettingsScreen(),
    ),
    GoRoute(
      path: '/settings/privacy',
      builder: (context, state) => const PrivacySettingsScreen(),
    ),
    GoRoute(
      path: '/settings/help',
      builder: (context, state) => const HelpSupportScreen(),
    ),
    GoRoute(
      path: '/subscription',
      builder: (context, state) => const SubscriptionScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/gesture-detail',
      builder: (context, state) {
        final data = state.extra as Map<String, String>;
        return GestureDetailScreen(gestureData: data);
      },
    ),
  ],
);
