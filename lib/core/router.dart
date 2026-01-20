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
import '../screens/settings/terms_conditions_screen.dart';
import '../screens/settings/privacy_policy_screen.dart';

// Helper function for custom premium transitions
Page<dynamic> _buildPageWithAnimation(Widget child, GoRouterState state) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Premium Fade + Subtle Slide Transition
      return FadeTransition(
        opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero)
              .animate(CurveTween(curve: Curves.easeOut).animate(animation)),
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => _buildPageWithAnimation(const SplashScreen(), state),
    ),
    GoRoute(
      path: '/onboarding',
      pageBuilder: (context, state) => _buildPageWithAnimation(const AppOnboardingScreen(), state),
    ),
    GoRoute(
      path: '/auth',
      pageBuilder: (context, state) => _buildPageWithAnimation(const AuthScreen(), state),
    ),
    GoRoute(
      path: '/main',
      pageBuilder: (context, state) => _buildPageWithAnimation(const MainNavigationWrapper(), state),
    ),
    GoRoute(
      path: '/voice-library',
      pageBuilder: (context, state) => _buildPageWithAnimation(const VoiceLibraryScreen(), state),
    ),
    GoRoute(
      path: '/voice-wizard',
      pageBuilder: (context, state) => _buildPageWithAnimation(const VoiceCreationWizard(), state),
    ),
    GoRoute(
      path: '/learning',
      pageBuilder: (context, state) => _buildPageWithAnimation(const GestureLibraryScreen(), state),
    ),
    GoRoute(
      path: '/practice',
      pageBuilder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return _buildPageWithAnimation(PracticeModeScreen(gestureName: data['gestureName']), state);
      },
    ),
    GoRoute(
      path: '/history',
      pageBuilder: (context, state) => _buildPageWithAnimation(const HistoryScreen(), state),
    ),
    GoRoute(
      path: '/account-settings',
      pageBuilder: (context, state) => _buildPageWithAnimation(const AccountSettingsScreen(), state),
    ),
    GoRoute(
      path: '/settings/language',
      pageBuilder: (context, state) => _buildPageWithAnimation(const LanguageSettingsScreen(), state),
    ),
    GoRoute(
      path: '/settings/accessibility',
      pageBuilder: (context, state) => _buildPageWithAnimation(const AccessibilitySettingsScreen(), state),
    ),
    GoRoute(
      path: '/settings/privacy',
      pageBuilder: (context, state) => _buildPageWithAnimation(const PrivacySettingsScreen(), state),
    ),
    GoRoute(
      path: '/settings/help',
      pageBuilder: (context, state) => _buildPageWithAnimation(const HelpSupportScreen(), state),
    ),
    GoRoute(
      path: '/settings/subscription',
      pageBuilder: (context, state) => _buildPageWithAnimation(const SubscriptionScreen(), state),
    ),
    GoRoute(
      path: '/notifications',
      pageBuilder: (context, state) => _buildPageWithAnimation(const NotificationsScreen(), state),
    ),
    GoRoute(
      path: '/gesture-detail',
      pageBuilder: (context, state) {
        final data = state.extra as Map<String, String>;
        return _buildPageWithAnimation(GestureDetailScreen(gestureData: data), state);
      },
    ),
    GoRoute(
      path: '/settings/terms',
      pageBuilder: (context, state) => _buildPageWithAnimation(const TermsConditionsScreen(), state),
    ),
    GoRoute(
      path: '/settings/privacy-policy',
      pageBuilder: (context, state) => _buildPageWithAnimation(const PrivacyPolicyScreen(), state),
    ),
  ],
);
