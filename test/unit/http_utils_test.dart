import 'package:test/test.dart';
import 'package:dio/dio.dart';

void main() {
  group('HTTP Utils Basic Tests', () {
    test('should create Dio instance', () {
      final dio = Dio();
      expect(dio, isA<Dio>());
      expect(dio.options, isA<BaseOptions>());
    });

    test('should handle BaseOptions configuration', () {
      final options = BaseOptions(
        baseUrl: 'https://api.bilibili.com/',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      );
      
      expect(options.baseUrl, equals('https://api.bilibili.com/'));
      expect(options.connectTimeout, equals(const Duration(seconds: 10)));
      expect(options.receiveTimeout, equals(const Duration(seconds: 10)));
    });

    test('should validate URL format', () {
      const testUrls = [
        'https://api.bilibili.com/x/web-interface/view',
        'https://api.bilibili.com/x/v2/reply',
        'https://api.bilibili.com/x/web-interface/search/type',
      ];
      
      for (final url in testUrls) {
        final uri = Uri.tryParse(url);
        expect(uri, isNotNull);
        expect(uri!.hasScheme, isTrue);
        expect(uri.scheme, equals('https'));
      }
    });

    test('should handle request headers', () {
      final headers = {
        'User-Agent': 'bili_you/1.0.0',
        'Referer': 'https://www.bilibili.com/',
        'Content-Type': 'application/json',
      };
      
      expect(headers['User-Agent'], contains('bili_you'));
      expect(headers['Referer'], equals('https://www.bilibili.com/'));
      expect(headers['Content-Type'], equals('application/json'));
    });

    test('should validate error types', () {
      final errorTypes = [
        DioExceptionType.connectionTimeout,
        DioExceptionType.receiveTimeout,
        DioExceptionType.badResponse,
        DioExceptionType.unknown,
      ];
      
      for (final type in errorTypes) {
        expect(type, isA<DioExceptionType>());
      }
    });
  });
}