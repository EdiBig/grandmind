import 'package:flutter_test/flutter_test.dart';
import 'package:kinesa/core/utils/validators.dart';

void main() {
  group('Validators', () {
    group('validateEmail', () {
      test('returns error when email is null', () {
        expect(Validators.validateEmail(null), 'Email is required');
      });

      test('returns error when email is empty', () {
        expect(Validators.validateEmail(''), 'Email is required');
      });

      test('returns error for invalid email format - no @', () {
        expect(
          Validators.validateEmail('invalidemail.com'),
          'Please enter a valid email address',
        );
      });

      test('returns error for invalid email format - no domain', () {
        expect(
          Validators.validateEmail('invalid@'),
          'Please enter a valid email address',
        );
      });

      test('returns error for invalid email format - no TLD', () {
        expect(
          Validators.validateEmail('invalid@domain'),
          'Please enter a valid email address',
        );
      });

      test('returns error for invalid email format - short TLD', () {
        expect(
          Validators.validateEmail('invalid@domain.c'),
          'Please enter a valid email address',
        );
      });

      test('returns null for valid email', () {
        expect(Validators.validateEmail('valid@email.com'), isNull);
      });

      test('returns null for valid email with subdomain', () {
        expect(Validators.validateEmail('user@mail.example.com'), isNull);
      });

      test('returns null for valid email with plus sign', () {
        expect(Validators.validateEmail('user+tag@email.com'), isNull);
      });

      test('returns null for valid email with dots', () {
        expect(Validators.validateEmail('first.last@email.co.uk'), isNull);
      });
    });

    group('validatePassword', () {
      test('returns error when password is null', () {
        expect(Validators.validatePassword(null), 'Password is required');
      });

      test('returns error when password is empty', () {
        expect(Validators.validatePassword(''), 'Password is required');
      });

      test('returns error when password is too short', () {
        expect(
          Validators.validatePassword('Short1'),
          'Password must be at least 8 characters',
        );
      });

      test('returns error when password has no uppercase', () {
        expect(
          Validators.validatePassword('password123'),
          'Password must contain at least one uppercase letter',
        );
      });

      test('returns error when password has no lowercase', () {
        expect(
          Validators.validatePassword('PASSWORD123'),
          'Password must contain at least one lowercase letter',
        );
      });

      test('returns error when password has no number', () {
        expect(
          Validators.validatePassword('Passworddd'),
          'Password must contain at least one number',
        );
      });

      test('returns null for valid password', () {
        expect(Validators.validatePassword('Password123'), isNull);
      });

      test('returns null for valid password with special chars', () {
        expect(Validators.validatePassword('Password123!@#'), isNull);
      });

      test('returns null for long valid password', () {
        expect(
          Validators.validatePassword('VeryLongPassword123WithManyChars'),
          isNull,
        );
      });
    });

    group('validateConfirmPassword', () {
      test('returns error when confirmation is null', () {
        expect(
          Validators.validateConfirmPassword(null, 'Password123'),
          'Please confirm your password',
        );
      });

      test('returns error when confirmation is empty', () {
        expect(
          Validators.validateConfirmPassword('', 'Password123'),
          'Please confirm your password',
        );
      });

      test('returns error when passwords do not match', () {
        expect(
          Validators.validateConfirmPassword('Different123', 'Password123'),
          'Passwords do not match',
        );
      });

      test('returns null when passwords match', () {
        expect(
          Validators.validateConfirmPassword('Password123', 'Password123'),
          isNull,
        );
      });
    });

    group('validateRequired', () {
      test('returns error when value is null', () {
        expect(
          Validators.validateRequired(null),
          'This field is required',
        );
      });

      test('returns error when value is empty', () {
        expect(
          Validators.validateRequired(''),
          'This field is required',
        );
      });

      test('returns error when value is only whitespace', () {
        expect(
          Validators.validateRequired('   '),
          'This field is required',
        );
      });

      test('returns custom error with fieldName', () {
        expect(
          Validators.validateRequired(null, fieldName: 'Username'),
          'Username is required',
        );
      });

      test('returns null when value is provided', () {
        expect(Validators.validateRequired('value'), isNull);
      });
    });

    group('validateName', () {
      test('returns error when name is null', () {
        expect(Validators.validateName(null), 'Name is required');
      });

      test('returns error when name is empty', () {
        expect(Validators.validateName(''), 'Name is required');
      });

      test('returns error when name is too short', () {
        expect(
          Validators.validateName('A'),
          'Name must be at least 2 characters',
        );
      });

      test('returns error when name contains numbers', () {
        expect(
          Validators.validateName('John123'),
          'Name can only contain letters, spaces, and hyphens',
        );
      });

      test('returns error when name contains special characters', () {
        expect(
          Validators.validateName('John@Doe'),
          'Name can only contain letters, spaces, and hyphens',
        );
      });

      test('returns null for valid name', () {
        expect(Validators.validateName('John'), isNull);
      });

      test('returns null for valid name with space', () {
        expect(Validators.validateName('John Doe'), isNull);
      });

      test('returns null for valid name with hyphen', () {
        expect(Validators.validateName('Mary-Jane'), isNull);
      });

      test('returns null for valid name with apostrophe', () {
        expect(Validators.validateName("O'Connor"), isNull);
      });
    });

    group('validateNumber', () {
      test('returns error when value is null', () {
        expect(
          Validators.validateNumber(null),
          'This field is required',
        );
      });

      test('returns error when value is empty', () {
        expect(
          Validators.validateNumber(''),
          'This field is required',
        );
      });

      test('returns error when value is not a number', () {
        expect(
          Validators.validateNumber('abc'),
          'Please enter a valid number',
        );
      });

      test('returns error when value is below minimum', () {
        expect(
          Validators.validateNumber('5', fieldName: 'Age', min: 10),
          'Age must be at least 10.0',
        );
      });

      test('returns error when value is above maximum', () {
        expect(
          Validators.validateNumber('150', fieldName: 'Age', max: 120),
          'Age must be at most 120.0',
        );
      });

      test('returns null for valid number', () {
        expect(Validators.validateNumber('50'), isNull);
      });

      test('returns null for valid number within range', () {
        expect(
          Validators.validateNumber('50', min: 0, max: 100),
          isNull,
        );
      });

      test('returns null for valid decimal number', () {
        expect(Validators.validateNumber('50.5'), isNull);
      });
    });

    group('validateWeight', () {
      test('returns error when weight is null', () {
        expect(
          Validators.validateWeight(null),
          'Weight is required',
        );
      });

      test('returns error when weight is below minimum (30kg)', () {
        expect(
          Validators.validateWeight('25'),
          'Weight must be at least 30.0',
        );
      });

      test('returns error when weight is above maximum (300kg)', () {
        expect(
          Validators.validateWeight('350'),
          'Weight must be at most 300.0',
        );
      });

      test('returns null for valid weight', () {
        expect(Validators.validateWeight('75'), isNull);
      });

      test('returns null for valid weight at minimum', () {
        expect(Validators.validateWeight('30'), isNull);
      });

      test('returns null for valid weight at maximum', () {
        expect(Validators.validateWeight('300'), isNull);
      });
    });

    group('validateHeight', () {
      test('returns error when height is null', () {
        expect(
          Validators.validateHeight(null),
          'Height is required',
        );
      });

      test('returns error when height is below minimum (100cm)', () {
        expect(
          Validators.validateHeight('90'),
          'Height must be at least 100.0',
        );
      });

      test('returns error when height is above maximum (250cm)', () {
        expect(
          Validators.validateHeight('260'),
          'Height must be at most 250.0',
        );
      });

      test('returns null for valid height', () {
        expect(Validators.validateHeight('175'), isNull);
      });
    });

    group('validateAge', () {
      test('returns error when age is null', () {
        expect(
          Validators.validateAge(null),
          'Age is required',
        );
      });

      test('returns error when age is below minimum (13)', () {
        expect(
          Validators.validateAge('10'),
          'Age must be at least 13.0',
        );
      });

      test('returns error when age is above maximum (120)', () {
        expect(
          Validators.validateAge('130'),
          'Age must be at most 120.0',
        );
      });

      test('returns null for valid age', () {
        expect(Validators.validateAge('25'), isNull);
      });
    });

    group('validatePhone', () {
      test('returns error when phone is null', () {
        expect(
          Validators.validatePhone(null),
          'Phone number is required',
        );
      });

      test('returns error when phone is empty', () {
        expect(
          Validators.validatePhone(''),
          'Phone number is required',
        );
      });

      test('returns error when phone contains letters', () {
        expect(
          Validators.validatePhone('123-abc-7890'),
          'Please enter a valid phone number',
        );
      });

      test('returns error when phone is too short', () {
        expect(
          Validators.validatePhone('12345'),
          'Phone number must be at least 10 digits',
        );
      });

      test('returns null for valid phone with just digits', () {
        expect(Validators.validatePhone('1234567890'), isNull);
      });

      test('returns null for valid phone with dashes', () {
        expect(Validators.validatePhone('123-456-7890'), isNull);
      });

      test('returns null for valid phone with spaces', () {
        expect(Validators.validatePhone('123 456 7890'), isNull);
      });

      test('returns null for valid phone with country code', () {
        expect(Validators.validatePhone('+1 234 567 8901'), isNull);
      });

      test('returns null for valid phone with parentheses', () {
        expect(Validators.validatePhone('(123) 456-7890'), isNull);
      });
    });
  });
}
