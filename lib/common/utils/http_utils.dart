import 'dart:developer';

import 'package:bili_you/common/api/index.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class HttpUtils {
  static final HttpUtils _instance = HttpUtils._internal();
  factory HttpUtils() => _instance;
  static late final Dio dio;
  static late final CookieManager cookieManager;
  CancelToken _cancelToken = CancelToken();

  ///初始化构造
  HttpUtils._internal() {
    BaseOptions options = BaseOptions(
      baseUrl: 'https://api.bilibili.com',
      headers: {
        'keep-alive': true,
        'user-agent': ApiConstants.userAgent,
        'Accept-Encoding': 'gzip',
        'Referer': 'https://www.bilibili.com/',
      },
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      contentType: Headers.jsonContentType,
      persistentConnection: true,
    );
    dio = Dio(options);
    dio.transformer = BackgroundTransformer();

    // 添加error拦截器
    dio.interceptors.add(ErrorInterceptor());
  }

  ///初始化设置
  Future<void> init() async {
    if (kIsWeb) {
      cookieManager = CookieManager(CookieJar());
    } else {
      //设置cookie存放的位置，保存cookie
      var cookiePath =
          "${(await getApplicationSupportDirectory()).path}/.cookies/";
      cookieManager =
          CookieManager(PersistCookieJar(storage: FileStorage(cookiePath)));
    }
    dio.interceptors.add(cookieManager);
    if ((await cookieManager.cookieJar
            .loadForRequest(Uri.parse(ApiConstants.bilibiliBase)))
        .isEmpty) {
      try {
        await dio.get("/"); //获取默认cookie
      } catch (e) {
        log("utils/my_dio, ${e.toString()}");
      }
    }
  }

  // 关闭dio
  void cancelRequests({required CancelToken token}) {
    _cancelToken.cancel("cancelled");
    _cancelToken = token;
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      // 确保路径格式正确
      String fullPath = path;
      if (!path.startsWith('http') && dio.options.baseUrl.isNotEmpty) {
        // 如果路径不以http开头，且baseUrl不为空，则使用baseUrl
        if (!path.startsWith('/')) {
          fullPath = '/$path';
        }
      } else if (!path.startsWith('http') && dio.options.baseUrl.isEmpty) {
        // 如果路径不以http开头，且baseUrl为空，则添加默认baseUrl
        if (!path.startsWith('/')) {
          fullPath = '/$path';
        }
        fullPath = 'https://api.bilibili.com$fullPath';
      }
      
      print('HTTP GET request to: $fullPath');
      print('Query parameters: $queryParameters');
      
      var response = await dio.get(
        fullPath,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken ?? _cancelToken,
      );
      print('HTTP GET response status: ${response.statusCode}');
      print('HTTP GET response data: ${response.data}');
      return response;
    } catch (e) {
      print('HTTP GET error for $path: $e');
      rethrow;
    }
  }

  Future post(
    String path, {
    Map<String, dynamic>? queryParameters,
    data,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      print('HTTP POST request to: $path');
      var response = await dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken ?? _cancelToken,
      );
      print('HTTP POST response status: ${response.statusCode}');
      return response;
    } catch (e) {
      print('HTTP POST error for $path: $e');
      rethrow;
    }
  }
}

/// 错误处理拦截器
class ErrorInterceptor extends Interceptor {
  // 是否有网
  Future<bool> isConnected() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    print('Dio error: ${err.type}, message: ${err.message}');
    
    // 注释掉所有错误提示，避免弹出服务器错误消息通知
    /*
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
        Get.rawSnackbar(title: '连接超时', message: '请检查网络连接');
        break;
      case DioExceptionType.receiveTimeout:
        Get.rawSnackbar(title: '接收超时', message: '服务器响应超时');
        break;
      case DioExceptionType.sendTimeout:
        Get.rawSnackbar(title: '发送超时', message: '请求发送超时');
        break;
      case DioExceptionType.badResponse:
        Get.rawSnackbar(title: '服务器错误', message: '服务器返回错误状态码');
        break;
      case DioExceptionType.cancel:
        // 请求被取消，通常不需要提示
        break;
      case DioExceptionType.unknown:
        if (!await isConnected()) {
          //网络未连接
          Get.rawSnackbar(title: '网络未连接', message: '请检查网络状态');
        } else {
          Get.rawSnackbar(title: '网络错误', message: '未知网络错误');
        }
        break;
      default:
        Get.rawSnackbar(title: '请求失败', message: '网络请求失败');
    }
    */

    return super.onError(err, handler);
  }
}