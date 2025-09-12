import 'package:test/test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bili_you/common/utils/settings.dart';

void main() {
  group('SettingsUtil Tests', () {
    setUp(() async {
      // 在每个测试前清理 SharedPreferences
      SharedPreferences.setMockInitialValues({});
      await SettingsUtil.init();
    });

    group('Basic Settings Operations', () {
      test('should store and retrieve string values', () async {
        const key = 'test_string_key';
        const value = 'test_value';
        
        await SettingsUtil.setValue(key, value);
        final retrieved = SettingsUtil.getValue(key);
        
        expect(retrieved, equals(value));
      });

      test('should store and retrieve integer values', () async {
        const key = 'test_int_key';
        const value = 42;
        
        await SettingsUtil.setValue(key, value);
        final retrieved = SettingsUtil.getValue(key);
        
        expect(retrieved, equals(value));
      });

      test('should store and retrieve boolean values', () async {
        const key = 'test_bool_key';
        const value = true;
        
        await SettingsUtil.setValue(key, value);
        final retrieved = SettingsUtil.getValue(key);
        
        expect(retrieved, equals(value));
      });

      test('should store and retrieve double values', () async {
        const key = 'test_double_key';
        const value = 3.14;
        
        await SettingsUtil.setValue(key, value);
        final retrieved = SettingsUtil.getValue(key);
        
        expect(retrieved, equals(value));
      });
    });

    group('Default Values', () {
      test('should return default value for non-existent key', () {
        const key = 'non_existent_key';
        const defaultValue = 'default';
        
        final retrieved = SettingsUtil.getValue(key, defaultValue: defaultValue);
        
        expect(retrieved, equals(defaultValue));
      });

      test('should return null for non-existent key without default', () {
        const key = 'non_existent_key';
        
        final retrieved = SettingsUtil.getValue(key);
        
        expect(retrieved, isNull);
      });
    });

    group('Settings Keys', () {
      test('should handle predefined settings keys', () {
        // 测试一些预定义的设置键
        const themeKey = SettingsStorageKeys.themeMode;
        const textScaleKey = SettingsStorageKeys.textScaleFactor;
        
        expect(themeKey, isA<String>());
        expect(textScaleKey, isA<String>());
        expect(themeKey.isNotEmpty, isTrue);
        expect(textScaleKey.isNotEmpty, isTrue);
      });
    });

    group('Theme Settings', () {
      test('should handle theme mode settings', () async {
        const themeKey = SettingsStorageKeys.themeMode;
        const themeValue = 1; // 假设 1 代表深色主题
        
        await SettingsUtil.setValue(themeKey, themeValue);
        final retrieved = SettingsUtil.getValue(themeKey);
        
        expect(retrieved, equals(themeValue));
      });
    });

    group('Text Scale Settings', () {
      test('should handle text scale factor settings', () async {
        const textScaleKey = SettingsStorageKeys.textScaleFactor;
        const textScaleValue = 1.2;
        
        await SettingsUtil.setValue(textScaleKey, textScaleValue);
        final retrieved = SettingsUtil.getValue(textScaleKey, defaultValue: 1.0);
        
        expect(retrieved, equals(textScaleValue));
      });

      test('should use default text scale factor when not set', () {
        const textScaleKey = SettingsStorageKeys.textScaleFactor;
        const defaultValue = 1.0;
        
        final retrieved = SettingsUtil.getValue(textScaleKey, defaultValue: defaultValue);
        
        expect(retrieved, equals(defaultValue));
      });
    });

    group('Settings Validation', () {
      test('should handle invalid key gracefully', () {
        expect(() => SettingsUtil.getValue(''), returnsNormally);
        expect(() => SettingsUtil.getValue(null), throwsA(isA<TypeError>()));
      });
    });
  });
}