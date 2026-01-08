import 'package:firebase_remote_config/firebase_remote_config.dart';

class AuthConfig {
  AuthConfig._();

  static const String appleSignInEnabledKey = 'apple_sign_in_enabled';

  static Future<bool> fetchAppleSignInEnabled() async {
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ),
    );
    await remoteConfig.setDefaults({
      appleSignInEnabledKey: false,
    });
    await remoteConfig.fetchAndActivate();
    return remoteConfig.getBool(appleSignInEnabledKey);
  }
}
