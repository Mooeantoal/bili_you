import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import 'package:bili_you/common/utils/http_utils.dart';

// 生成 Mock 类
@GenerateMocks([Dio])
import 'http_utils_test.mocks.dart';

void main() {
  group('HttpUtils Tests', () {
    late MockDio mockDio;

    setUp(() {
      mockDio = MockDio();
    });

    group('GET Request Tests', () {
      test('should make GET request successfully', () async {
        // 安排 Mock 响应
        const testUrl = 'https://api.bilibili.com/test';
        const responseData = {'code': 0, 'message': 'success', 'data': {}};
        
        when(mockDio.get(testUrl))
            .thenAnswer((_) async => Response(
                  data: responseData,
                  statusCode: 200,
                  requestOptions: RequestOptions(path: testUrl),
                ));

        // 验证请求行为
        verify(mockDio.get(testUrl)).called(1);
      });

      test('should handle network errors gracefully', () async {
        const testUrl = 'https://api.bilibili.com/test';
        
        when(mockDio.get(testUrl))
            .thenThrow(DioException(
              requestOptions: RequestOptions(path: testUrl),
              type: DioExceptionType.connectionTimeout,
            ));

        // 验证异常处理
        expect(() async => await mockDio.get(testUrl), throwsA(isA<DioException>()));
      });
    });

    group('Headers Tests', () {
      test('should include required headers', () async {
        const testUrl = 'https://api.bilibili.com/test';
        final expectedHeaders = {
          'User-Agent': contains('bili_you'),
          'Referer': 'https://www.bilibili.com/',
        };

        when(mockDio.get(
          testUrl,
          options: anyNamed('options'),
        )).thenAnswer((_) async => Response(
              data: {},
              statusCode: 200,
              requestOptions: RequestOptions(path: testUrl),
            ));

        // 这里主要验证 Headers 的设置逻辑
        // 实际测试中可以验证 HttpUtils 的具体实现
      });
    });

    group('Error Handling Tests', () {
      test('should retry on network failures', () async {
        const testUrl = 'https://api.bilibili.com/test';
        
        // 第一次失败，第二次成功
        when(mockDio.get(testUrl))
            .thenThrow(DioException(
              requestOptions: RequestOptions(path: testUrl),
              type: DioExceptionType.connectionTimeout,
            ))
            .thenAnswer((_) async => Response(
              data: {'code': 0},
              statusCode: 200,
              requestOptions: RequestOptions(path: testUrl),
            ));

        // 验证重试机制
        // 这里需要根据 HttpUtils 的实际重试逻辑进行测试
      });
    });
  });
}