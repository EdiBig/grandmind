import 'package:flutter_test/flutter_test.dart';
import 'package:kinesa/core/utils/helpers.dart';

void main() {
  group('Helpers', () {
    group('calculateBMI', () {
      test('calculates BMI correctly for normal weight', () {
        // 70kg, 175cm = 70 / (1.75^2) = 22.86
        final bmi = Helpers.calculateBMI(70, 175);
        expect(bmi, closeTo(22.86, 0.01));
      });

      test('calculates BMI correctly for overweight', () {
        // 90kg, 175cm = 90 / (1.75^2) = 29.39
        final bmi = Helpers.calculateBMI(90, 175);
        expect(bmi, closeTo(29.39, 0.01));
      });

      test('calculates BMI correctly for underweight', () {
        // 50kg, 175cm = 50 / (1.75^2) = 16.33
        final bmi = Helpers.calculateBMI(50, 175);
        expect(bmi, closeTo(16.33, 0.01));
      });

      test('calculates BMI correctly for obese', () {
        // 110kg, 175cm = 110 / (1.75^2) = 35.92
        final bmi = Helpers.calculateBMI(110, 175);
        expect(bmi, closeTo(35.92, 0.01));
      });
    });

    group('getBMICategory', () {
      test('returns Underweight for BMI < 18.5', () {
        expect(Helpers.getBMICategory(15.0), 'Underweight');
        expect(Helpers.getBMICategory(18.4), 'Underweight');
      });

      test('returns Normal for BMI between 18.5 and 24.9', () {
        expect(Helpers.getBMICategory(18.5), 'Normal');
        expect(Helpers.getBMICategory(22.0), 'Normal');
        expect(Helpers.getBMICategory(24.9), 'Normal');
      });

      test('returns Overweight for BMI between 25 and 29.9', () {
        expect(Helpers.getBMICategory(25.0), 'Overweight');
        expect(Helpers.getBMICategory(27.5), 'Overweight');
        expect(Helpers.getBMICategory(29.9), 'Overweight');
      });

      test('returns Obese for BMI >= 30', () {
        expect(Helpers.getBMICategory(30.0), 'Obese');
        expect(Helpers.getBMICategory(35.0), 'Obese');
        expect(Helpers.getBMICategory(40.0), 'Obese');
      });
    });

    group('getMotivationalTip', () {
      test('returns a non-empty string', () {
        final tip = Helpers.getMotivationalTip();
        expect(tip, isNotEmpty);
        expect(tip, isA<String>());
      });

      test('returns one of the predefined tips', () {
        final validTips = [
          'Small steps every day lead to big changes',
          'Your body can do it, it\'s your mind you need to convince',
          'The only bad workout is the one you didn\'t do',
          'Progress is progress, no matter how small',
          'Consistency is key to success',
          'Believe in yourself and your goals',
          'Every workout counts toward your goal',
          'You\'re stronger than you think',
          'Make time for your health today',
          'Your future self will thank you',
        ];
        final tip = Helpers.getMotivationalTip();
        expect(validTips.contains(tip), isTrue);
      });
    });

    group('calculateStreak', () {
      test('returns 0 for empty list', () {
        expect(Helpers.calculateStreak([]), 0);
      });

      test('returns 0 when last activity is more than 1 day ago', () {
        final dates = [
          DateTime.now().subtract(const Duration(days: 3)),
        ];
        expect(Helpers.calculateStreak(dates), 0);
      });

      test('returns 1 for activity only today', () {
        final dates = [DateTime.now()];
        expect(Helpers.calculateStreak(dates), 1);
      });

      test('returns 1 for activity only yesterday', () {
        final dates = [
          DateTime.now().subtract(const Duration(days: 1)),
        ];
        expect(Helpers.calculateStreak(dates), 1);
      });

      test('returns correct streak for consecutive days including today', () {
        final now = DateTime.now();
        final dates = [
          now,
          now.subtract(const Duration(days: 1)),
          now.subtract(const Duration(days: 2)),
        ];
        expect(Helpers.calculateStreak(dates), 3);
      });

      test('returns correct streak for consecutive days including yesterday', () {
        final now = DateTime.now();
        final dates = [
          now.subtract(const Duration(days: 1)),
          now.subtract(const Duration(days: 2)),
          now.subtract(const Duration(days: 3)),
        ];
        expect(Helpers.calculateStreak(dates), 3);
      });

      test('breaks streak when there is a gap', () {
        final now = DateTime.now();
        final dates = [
          now,
          now.subtract(const Duration(days: 1)),
          now.subtract(const Duration(days: 3)), // Gap - day 2 is missing
        ];
        expect(Helpers.calculateStreak(dates), 2);
      });

      test('handles unsorted dates correctly', () {
        final now = DateTime.now();
        final dates = [
          now.subtract(const Duration(days: 2)),
          now,
          now.subtract(const Duration(days: 1)),
        ];
        expect(Helpers.calculateStreak(dates), 3);
      });
    });

    group('isToday', () {
      test('returns true for today', () {
        expect(Helpers.isToday(DateTime.now()), isTrue);
      });

      test('returns true for today with different time', () {
        final todayMorning = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          8,
          0,
        );
        expect(Helpers.isToday(todayMorning), isTrue);
      });

      test('returns false for yesterday', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        expect(Helpers.isToday(yesterday), isFalse);
      });

      test('returns false for tomorrow', () {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        expect(Helpers.isToday(tomorrow), isFalse);
      });
    });

    group('isYesterday', () {
      test('returns true for yesterday', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        expect(Helpers.isYesterday(yesterday), isTrue);
      });

      test('returns true for yesterday with different time', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final yesterdayEvening = DateTime(
          yesterday.year,
          yesterday.month,
          yesterday.day,
          20,
          0,
        );
        expect(Helpers.isYesterday(yesterdayEvening), isTrue);
      });

      test('returns false for today', () {
        expect(Helpers.isYesterday(DateTime.now()), isFalse);
      });

      test('returns false for two days ago', () {
        final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
        expect(Helpers.isYesterday(twoDaysAgo), isFalse);
      });
    });

    group('getGreeting', () {
      test('returns appropriate greeting based on time of day', () {
        final greeting = Helpers.getGreeting();
        expect(
          greeting,
          anyOf('Good morning', 'Good afternoon', 'Good evening'),
        );
      });
    });

    group('capitalize', () {
      test('capitalizes first letter', () {
        expect(Helpers.capitalize('hello'), 'Hello');
      });

      test('returns empty string for empty input', () {
        expect(Helpers.capitalize(''), '');
      });

      test('handles already capitalized string', () {
        expect(Helpers.capitalize('Hello'), 'Hello');
      });

      test('handles single character', () {
        expect(Helpers.capitalize('a'), 'A');
      });

      test('only capitalizes first letter, keeps rest unchanged', () {
        expect(Helpers.capitalize('hELLO'), 'HELLO');
      });
    });

    group('snakeToTitleCase', () {
      test('converts snake_case to Title Case', () {
        expect(Helpers.snakeToTitleCase('hello_world'), 'Hello World');
      });

      test('handles single word', () {
        expect(Helpers.snakeToTitleCase('hello'), 'Hello');
      });

      test('handles multiple underscores', () {
        expect(
          Helpers.snakeToTitleCase('hello_beautiful_world'),
          'Hello Beautiful World',
        );
      });

      test('handles already lowercase', () {
        expect(Helpers.snakeToTitleCase('hello'), 'Hello');
      });

      test('handles empty string', () {
        expect(Helpers.snakeToTitleCase(''), '');
      });
    });
  });
}
