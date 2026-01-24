import 'dart:io' show Platform;

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kinesa/features/health/data/services/health_service.dart';
import 'package:health/health.dart';

const bool _runHealthIntegration = bool.fromEnvironment(
  'RUN_HEALTH_INTEGRATION',
  defaultValue: false,
);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Health integration writes a workout (device-only)',
    (tester) async {
      if (!_runHealthIntegration) {
        return;
      }

      if (!Platform.isAndroid && !Platform.isIOS) {
        return;
      }

      final healthService = HealthService();
      final status = await healthService.getHealthConnectStatus();
      // ignore: avoid_print
      print('Health Connect status: $status');

      final hasPermissions = await healthService.hasPermissions() ||
          await healthService.requestAuthorization();
      // ignore: avoid_print
      print('Health permissions granted: $hasPermissions');

      expect(
        hasPermissions,
        isTrue,
        reason: 'Health permissions are required for this integration test.',
      );

      final now = DateTime.now();
      var success = await healthService.writeWorkout(
        activityType: HealthWorkoutActivityType.OTHER,
        startTime: now.subtract(const Duration(minutes: 5)),
        endTime: now.subtract(const Duration(minutes: 4)),
        totalEnergyBurned: 50,
        totalDistance: 0,
      );

      if (!success) {
        // Give the user a chance to enable write permissions in Health Connect.
        await healthService.openHealthConnectSettings();
        await Future<void>.delayed(const Duration(seconds: 10));
        await Future<void>.delayed(const Duration(seconds: 1));
        success = await healthService.writeWorkout(
          activityType: HealthWorkoutActivityType.WALKING,
          startTime: now.subtract(const Duration(minutes: 8)),
          endTime: now.subtract(const Duration(minutes: 7)),
          totalEnergyBurned: 30,
          totalDistance: 100,
        );
      }

      expect(
        success,
        isTrue,
        reason: 'Health writeWorkout returned false. '
            'Ensure Health Connect is installed, permissions allow workouts, '
            'and the app is allowed to write exercise data.',
      );
    },
    skip: !_runHealthIntegration,
  );
}
