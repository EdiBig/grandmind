import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/auth_config.dart';

final appleSignInEnabledProvider = FutureProvider<bool>((ref) async {
  try {
    return await AuthConfig.fetchAppleSignInEnabled();
  } catch (_) {
    return false;
  }
});
