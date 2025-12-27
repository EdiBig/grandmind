import 'package:health/health.dart';

class HealthService {
  final Health _health = Health();

  Future<bool> requestAuthorization() async {
    final types = [
      HealthDataType.STEPS,
      HealthDataType.WEIGHT,
      HealthDataType.HEIGHT,
      HealthDataType.ACTIVE_ENERGY_BURNED,
      HealthDataType.HEART_RATE,
      HealthDataType.SLEEP_ASLEEP,
      HealthDataType.WORKOUT,
    ];

    final permissions = types.map((type) => HealthDataAccess.READ_WRITE).toList();

    try {
      final granted = await _health.requestAuthorization(types, permissions: permissions);
      return granted ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<int?> getTodaySteps() async {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);

    try {
      final steps = await _health.getTotalStepsInInterval(midnight, now);
      return steps;
    } catch (e) {
      return null;
    }
  }

  Future<List<HealthDataPoint>> getHealthData({
    required DateTime startTime,
    required DateTime endTime,
    required List<HealthDataType> types,
  }) async {
    try {
      final granted = await requestAuthorization();
      if (!granted) {
        return [];
      }

      final healthData = await _health.getHealthDataFromTypes(
        startTime: startTime,
        endTime: endTime,
        types: types,
      );

      return healthData;
    } catch (e) {
      return [];
    }
  }

  Future<bool> writeHealthData({
    required HealthDataType type,
    required double value,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      final granted = await requestAuthorization();
      if (!granted) {
        return false;
      }

      final success = await _health.writeHealthData(
        value: value,
        type: type,
        startTime: startTime,
        endTime: endTime,
      );

      return success;
    } catch (e) {
      return false;
    }
  }
}
