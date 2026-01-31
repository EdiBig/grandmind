import 'package:go_router/go_router.dart';
import '../core/constants/route_constants.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/profile/presentation/screens/edit_profile_enhanced_screen.dart';

/// Profile related routes
List<GoRoute> profileRoutes = [
  GoRoute(
    path: RouteConstants.profile,
    name: 'profile',
    builder: (context, state) => const ProfileScreen(),
  ),
  GoRoute(
    path: RouteConstants.editProfile,
    name: 'editProfile',
    builder: (context, state) => const EditProfileEnhancedScreen(),
  ),
];
