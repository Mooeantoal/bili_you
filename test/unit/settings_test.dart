import 'package:test/test.dart';
import 'package:bili_you/common/utils/bili_you_storage.dart';
import 'package:flutter/material.dart';

void main() {
  group('SettingsStorageKeys Tests', () {
    test('should have predefined settings keys', () {
      // 测试一些预定义的设置键
      expect(SettingsStorageKeys.themeMode, isA<String>());
      expect(SettingsStorageKeys.textScaleFactor, isA<String>());
      expect(SettingsStorageKeys.defaultShowDanmaku, isA<String>());
      expect(SettingsStorageKeys.preferVideoQuality, isA<String>());
      
      expect(SettingsStorageKeys.themeMode.isNotEmpty, isTrue);
      expect(SettingsStorageKeys.textScaleFactor.isNotEmpty, isTrue);
    });

    test('should have theme mode key', () {
      expect(SettingsStorageKeys.themeMode, equals('themeMode'));
    });

    test('should have text scale factor key', () {
      expect(SettingsStorageKeys.textScaleFactor, equals('textScaleFactor'));
    });

    test('should have danmaku settings keys', () {
      expect(SettingsStorageKeys.defaultShowDanmaku, equals('defaultShowDanmaku'));
      expect(SettingsStorageKeys.defaultDanmakuSpeed, equals('defaultDanmakuSpeed'));
      expect(SettingsStorageKeys.defaultDanmakuScale, equals('defaultDanmakuScale'));
    });

    test('should have video settings keys', () {
      expect(SettingsStorageKeys.preferVideoQuality, equals('preferVideoQuality'));
      expect(SettingsStorageKeys.preferVideoCodec, equals('preferVideoCodec'));
      expect(SettingsStorageKeys.autoPlayOnInit, equals('autoPlayOnInit'));
    });

    test('should have valid key format', () {
      // 验证设置键的格式
      final keys = [
        SettingsStorageKeys.themeMode,
        SettingsStorageKeys.textScaleFactor,
        SettingsStorageKeys.defaultShowDanmaku,
      ];
      
      for (final key in keys) {
        expect(key, isNotEmpty);
        expect(key, isNot(contains(' '))); // 不应该包含空格
        expect(key, matches(r'^[a-zA-Z][a-zA-Z0-9]*$')); // 应该是驼峰命名
      }
    });
  });
}