import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_presets.dart';
import 'features/settings/presentation/providers/app_settings_provider.dart';
import 'routes/app_router.dart';

class KinesaApp extends ConsumerWidget {
  const KinesaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final settings = ref.watch(appSettingsProvider);
    final preset = ThemePresets.byId(settings.themePresetId);

    return MaterialApp.router(
      title: 'Kinesa',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData(
        preset: preset,
        brightness: Brightness.light,
      ),
      darkTheme: AppTheme.themeData(
        preset: preset,
        brightness: Brightness.dark,
      ),
      themeMode: settings.themeMode,
      routerConfig: router,
    );
  }
}
