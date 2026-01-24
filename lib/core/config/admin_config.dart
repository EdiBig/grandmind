import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/authentication/presentation/providers/auth_provider.dart';

/// List of admin email addresses
/// Add your email here to access admin features
const List<String> _adminEmails = [
  'admin@grandpoint.uk',
];

/// Provider to check if the current user is an admin
/// Watches auth state so it updates when user logs in/out
final isAdminProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) {
      if (user == null || user.email == null) return false;
      return _adminEmails
          .map((e) => e.toLowerCase())
          .contains(user.email!.toLowerCase());
    },
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Provider to get the current user's email (reactive)
final currentUserEmailProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.valueOrNull?.email;
});
