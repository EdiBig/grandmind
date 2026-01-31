import 'package:go_router/go_router.dart';
import '../core/constants/route_constants.dart';
import '../features/challenges/presentation/screens/create_challenge_screen.dart';
import '../features/challenges/presentation/screens/challenge_detail_screen.dart';
import '../features/challenges/presentation/screens/challenge_rankings_screen.dart';
import '../features/challenges/presentation/screens/challenge_activity_feed_screen.dart';
import '../features/challenges/presentation/screens/challenge_privacy_settings_screen.dart';
import '../features/challenges/presentation/screens/challenge_moderation_screen.dart';
import '../features/challenges/presentation/screens/blocked_users_screen.dart';

/// Challenge feature routes
List<GoRoute> challengeRoutes = [
  GoRoute(
    path: RouteConstants.createChallenge,
    name: 'createChallenge',
    builder: (context, state) => const CreateChallengeScreen(),
  ),
  GoRoute(
    path: RouteConstants.challengeDetail,
    name: 'challengeDetail',
    builder: (context, state) {
      final challengeId = state.pathParameters['id'] ?? '';
      return ChallengeDetailScreen(challengeId: challengeId);
    },
  ),
  GoRoute(
    path: RouteConstants.challengeRankings,
    name: 'challengeRankings',
    builder: (context, state) {
      final challengeId = state.pathParameters['id'] ?? '';
      return ChallengeRankingsScreen(challengeId: challengeId);
    },
  ),
  GoRoute(
    path: RouteConstants.challengeFeed,
    name: 'challengeFeed',
    builder: (context, state) {
      final challengeId = state.pathParameters['id'] ?? '';
      return ChallengeActivityFeedScreen(challengeId: challengeId);
    },
  ),
  GoRoute(
    path: RouteConstants.challengePrivacy,
    name: 'challengePrivacy',
    builder: (context, state) => const ChallengePrivacySettingsScreen(),
  ),
  GoRoute(
    path: RouteConstants.challengeModeration,
    name: 'challengeModeration',
    builder: (context, state) {
      final challengeId = state.pathParameters['id'] ?? '';
      final challengeName = state.extra as String? ?? 'Challenge';
      return ChallengeModerationScreen(
        challengeId: challengeId,
        challengeName: challengeName,
      );
    },
  ),
  GoRoute(
    path: RouteConstants.blockedUsers,
    name: 'blockedUsers',
    builder: (context, state) => const BlockedUsersScreen(),
  ),
];
