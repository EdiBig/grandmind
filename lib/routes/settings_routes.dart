import 'package:go_router/go_router.dart';
import '../core/constants/route_constants.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/settings/presentation/screens/data_management_screen.dart';
import '../features/settings/presentation/screens/privacy_screen.dart';
import '../features/settings/presentation/screens/help_center_screen.dart';
import '../features/settings/presentation/screens/about_screen.dart';
import '../features/settings/presentation/screens/terms_screen.dart';
import '../features/settings/presentation/screens/privacy_policy_screen.dart';
import '../features/settings/presentation/screens/community_guidelines_screen.dart';
import '../features/notifications/presentation/screens/notification_settings_screen.dart';

/// Settings and legal routes
List<GoRoute> settingsRoutes = [
  GoRoute(
    path: RouteConstants.settings,
    name: 'settings',
    builder: (context, state) => const SettingsScreen(),
  ),
  GoRoute(
    path: RouteConstants.notifications,
    name: 'notifications',
    builder: (context, state) => const NotificationSettingsScreen(),
  ),
  GoRoute(
    path: RouteConstants.dataManagement,
    name: 'dataManagement',
    builder: (context, state) => const DataManagementScreen(),
  ),
  GoRoute(
    path: RouteConstants.privacy,
    name: 'privacy',
    builder: (context, state) => const PrivacyScreen(),
  ),
  GoRoute(
    path: RouteConstants.communityGuidelines,
    name: 'communityGuidelines',
    builder: (context, state) => const CommunityGuidelinesScreen(),
  ),
  GoRoute(
    path: RouteConstants.help,
    name: 'help',
    builder: (context, state) => const HelpCenterScreen(),
  ),
  GoRoute(
    path: RouteConstants.about,
    name: 'about',
    builder: (context, state) => const AboutScreen(),
  ),
  GoRoute(
    path: RouteConstants.termsOfService,
    name: 'termsOfService',
    builder: (context, state) => const TermsScreen(),
  ),
  GoRoute(
    path: RouteConstants.privacyPolicy,
    name: 'privacyPolicy',
    builder: (context, state) => const PrivacyPolicyScreen(),
  ),
];
