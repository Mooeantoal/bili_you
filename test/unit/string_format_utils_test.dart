import 'package:test/test.dart';
import 'package:bili_you/common/utils/string_format_utils.dart';

void main() {
  group('StringFormatUtils Tests', () {
    group('numFormat', () {
      test('should format numbers under 1000 correctly', () {
        expect(StringFormatUtils.numFormat(0), equals('0'));
        expect(StringFormatUtils.numFormat(1), equals('1'));
        expect(StringFormatUtils.numFormat(999), equals('999'));
      });

      test('should format thousands correctly', () {
        expect(StringFormatUtils.numFormat(1000), equals('1.0k'));
        expect(StringFormatUtils.numFormat(1500), equals('1.5k'));
        expect(StringFormatUtils.numFormat(9999), equals('9.9k'));
      });

      test('should format ten thousands correctly', () {
        expect(StringFormatUtils.numFormat(10000), equals('1.0万'));
        expect(StringFormatUtils.numFormat(15000), equals('1.5万'));
        expect(StringFormatUtils.numFormat(99999), equals('9.9万'));
      });

      test('should format millions correctly', () {
        expect(StringFormatUtils.numFormat(1000000), equals('100.0万'));
        expect(StringFormatUtils.numFormat(1500000), equals('150.0万'));
      });

      test('should handle edge cases', () {
        expect(StringFormatUtils.numFormat(-1), equals('-1'));
        expect(StringFormatUtils.numFormat(null), equals('0'));
      });
    });

    group('timeLengthFormat', () {
      test('should format seconds correctly', () {
        expect(StringFormatUtils.timeLengthFormat(30), equals('0:30'));
        expect(StringFormatUtils.timeLengthFormat(59), equals('0:59'));
      });

      test('should format minutes correctly', () {
        expect(StringFormatUtils.timeLengthFormat(60), equals('1:00'));
        expect(StringFormatUtils.timeLengthFormat(90), equals('1:30'));
        expect(StringFormatUtils.timeLengthFormat(3599), equals('59:59'));
      });

      test('should format hours correctly', () {
        expect(StringFormatUtils.timeLengthFormat(3600), equals('1:00:00'));
        expect(StringFormatUtils.timeLengthFormat(3661), equals('1:01:01'));
        expect(StringFormatUtils.timeLengthFormat(7200), equals('2:00:00'));
      });

      test('should handle edge cases', () {
        expect(StringFormatUtils.timeLengthFormat(0), equals('0:00'));
        expect(StringFormatUtils.timeLengthFormat(-1), equals('0:00'));
      });
    });
  });
}