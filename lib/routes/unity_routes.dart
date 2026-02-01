import 'package:go_router/go_router.dart';

import '../features/unity/presentation/screens/screens.dart';

/// Unity feature routes
List<GoRoute> unityRoutes = [
  // Main Unity Hub
  GoRoute(
    path: '/unity',
    name: 'unity',
    builder: (context, state) => const UnityHubScreen(),
  ),

  // Discover Challenges
  GoRoute(
    path: '/unity/discover',
    name: 'discoverChallenges',
    builder: (context, state) => const DiscoverChallengesScreen(),
  ),

  // My Challenges
  GoRoute(
    path: '/unity/my-challenges',
    name: 'myChallenges',
    builder: (context, state) => const MyChallengesScreen(),
  ),

  // Challenge Detail
  GoRoute(
    path: '/unity/challenge/:id',
    name: 'challengeDetail',
    builder: (context, state) {
      final challengeId = state.pathParameters['id'] ?? '';
      return ChallengeDetailScreen(challengeId: challengeId);
    },
  ),

  // Join Challenge
  GoRoute(
    path: '/unity/challenge/:id/join',
    name: 'joinChallenge',
    builder: (context, state) {
      final challengeId = state.pathParameters['id'] ?? '';
      return JoinChallengeScreen(challengeId: challengeId);
    },
  ),

  // Challenge Feed
  GoRoute(
    path: '/unity/challenge/:id/feed',
    name: 'challengeFeed',
    builder: (context, state) {
      final challengeId = state.pathParameters['id'] ?? '';
      return ChallengeFeedScreen(challengeId: challengeId);
    },
  ),

  // Progress Portrait (non-competitive view)
  GoRoute(
    path: '/unity/challenge/:id/portrait',
    name: 'progressPortrait',
    builder: (context, state) {
      final challengeId = state.pathParameters['id'] ?? '';
      return ProgressPortraitScreen(challengeId: challengeId);
    },
  ),

  // Circles
  GoRoute(
    path: '/unity/my-circles',
    name: 'myCircles',
    builder: (context, state) => const MyCirclesScreen(),
  ),

  GoRoute(
    path: '/unity/create-circle',
    name: 'createCircle',
    builder: (context, state) => const CreateCircleScreen(),
  ),

  GoRoute(
    path: '/unity/circle/:id',
    name: 'circleDetail',
    builder: (context, state) {
      final circleId = state.pathParameters['id'] ?? '';
      return CircleDetailScreen(circleId: circleId);
    },
  ),

  GoRoute(
    path: '/unity/circle/:id/settings',
    name: 'circleSettings',
    builder: (context, state) {
      final circleId = state.pathParameters['id'] ?? '';
      return CircleSettingsScreen(circleId: circleId);
    },
  ),

  // Unity Settings
  GoRoute(
    path: '/unity/settings',
    name: 'unitySettings',
    builder: (context, state) => const UnitySettingsScreen(),
  ),
];
