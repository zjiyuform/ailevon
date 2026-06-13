// 基于Dio进行二次封装
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ailevon/constants/constants.dart';
import 'package:ailevon/stores/token_manager.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;
import 'package:ailevon/utils/widget/toast_utils.dart'; // 仅在 Web 平台使用

class DioRequest {
  final _dio = Dio(); // dio请求对象
  // 1 基础地址拦截器
  DioRequest() {
    _dio.options
      ..baseUrl = GlobalConstants.BASE_URL
      ..connectTimeout = Duration(seconds: GlobalConstants.TIME_OUT)
      ..sendTimeout = Duration(seconds: GlobalConstants.TIME_OUT)
      ..receiveTimeout = Duration(seconds: GlobalConstants.TIME_OUT);
    // 拦截器
    _addInterceptor();
  }

  // 2 添加拦截器
  void _addInterceptor() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        // 请求拦截
        onRequest: (request, handler) {
          // 注入token request headers Authorization = "Bearer token"
          if (tokenManager.getToken().isNotEmpty) {
            request.headers['Authorization'] =
                "Bearer ${tokenManager.getToken()}";
          }
          handler.next(request);
        },
        // 响应拦截
        onResponse: (response, handler) {
          // 根据状态码进行操作 ( ! 非空断言, 状态码不为空且大于等于200, 小于300)
          if (response.statusCode! >= 200 && response.statusCode! < 300) {
            handler.next(response);
            return;
          }
          handler.reject(DioException(requestOptions: response.requestOptions));
        },
        // 错误拦截
        onError: (error, handler) {
          handler.reject(error);
        },
      ),
    );
  }

  // 3 设置get请求方法(只获取items)
  Future<dynamic> getItems(
    String url, {
    Object? data,
    Map<String, dynamic>? params,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
  }) {
    return _handleResponse(
      _dio.get(
        url,
        data: data,
        queryParameters: params,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      ),
    );
  }

  // dio请求工具发出请求, 返回的数据是 Future<Response<dynamic>>.data
  // 把所有接口的data解放出来, 拿到真正的数据, 判断数据列表(items)是否存在

  // 4 进一步处理返回结果的函数 (处理Future需要使用then()方法等, 或async/await关键字)
  Future<dynamic> _handleResponse(Future<Response<dynamic>> task) async {
    try {
      Response<dynamic> res = await task; // await等待处理 get请求响应结果
      final data = res.data as Map<String, dynamic>; // 转化为Map数据结构
      // print(res);
      if (data["items"] != null) {
        // items 项存在, 就可以正常放行通过
        // print(data["items"]);
        return data["items"]; // 返回 items 的数据
      }
      // 抛出异常
      throw Exception("加载数据异常");
    } catch (e) {
      throw Exception(e);
    }
  }

  // pageNumber 后面才发现有这个参数,

  //  设置新的get请求方法
  Future<dynamic> getPageNumber(
    String url, {
    Object? data,
    Map<String, dynamic>? params,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
  }) {
    return _handleResponsePN(
      _dio.get(
        url,
        data: data,
        queryParameters: params,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      ),
    );
  }

  // 设置返回pageNumber的getPageNumber方法,和_handleResponsePN
  Future<dynamic> _handleResponsePN(Future<Response<dynamic>> task) async {
    try {
      Response<dynamic> res = await task; // await等待处理 get请求响应结果
      final data = res.data as Map<String, dynamic>; // 转化为Map数据结构
      // print(res);
      // print(data);
      if (data["items"] != null) {
        // items 项存在, 就可以正常放行通过
        // print(data["items"]);
        return data; // 返回 包含items,pageNumber的数据
      }
      // 抛出异常
      throw Exception("加载数据异常");
    } catch (e) {
      throw Exception(e);
    }
  }

  //
  //
  //
  //  Login请求 Post接口
  Future<dynamic> loginInfoPost(
    String url, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) {
    return _handleResponsePost(
      _dio.post(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      ),
    );
  }

  Future<dynamic> _handleResponsePost(
    Future<Response<dynamic>> task, {
    bool isRefresh = false,
  }) async {
    try {
      Response<dynamic> res = await task; // await等待处理 post请求响应结果
      await _extractAndSaveRefreshToken(res.headers);
      final token = res.data as String; // 转化为String数据结构
      // print(res);
      // print(token);
      // print("Response headers: ${res.headers}");
      if (token.isNotEmpty) {
        if (isRefresh) {
          return token;
        }
        Map<String, dynamic> data = JwtDecoder.decode(token);
        data = {...data, "token": token};
        // print(data);
        return data;
      }
      // 抛出异常
      throw Exception("加载数据异常");
    } catch (e) {
      throw Exception(e);
    }
  }

  /// 从响应头中提取 refresh-token 并安全存储
  Future<void> _extractAndSaveRefreshToken(Headers headers) async {
    List<String>? setCookieHeaders = headers['set-cookie'];
    // print(headers['set-cookie']);
    if (setCookieHeaders == null || setCookieHeaders.isEmpty) return;

    final regex = RegExp(r'(?:^|;)\s*refresh-token=([^;]+)');
    for (var header in setCookieHeaders) {
      final match = regex.firstMatch(header);
      if (match != null) {
        final refreshToken = match.group(1);
        // print('refreshToken: $refreshToken');
        if (refreshToken != null && refreshToken.isNotEmpty) {
          // 使用 TokenManager 存储
          await tokenManager.setRefreshToken(refreshToken);
          // print('Refresh token saved via TokenManager');
          break;
        }
      }
    }
  }

  //
  //
  //
  //  设置get获取小说详情请求方法
  Future<dynamic> getNovelDetails(
    String url, {
    Object? data,
    Map<String, dynamic>? params,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
  }) {
    return _handleResponseND(
      _dio.get(
        url,
        data: data,
        queryParameters: params,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      ),
    );
  }

  Future<dynamic> _handleResponseND(Future<Response<dynamic>> task) async {
    try {
      Response<dynamic> res = await task; // await等待处理 get请求响应结果
      final data = res.data as Map<String, dynamic>; // 转化为Map数据结构
      // print(res);
      return data;
    } catch (e) {
      throw Exception(e);
    }
  }

  // 获取是否暂停历史记录的get方法
  Future<dynamic> getIsPaused(
    String url, {
    Object? data,
    Map<String, dynamic>? params,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
  }) {
    return _handleResponseIsPaused(
      _dio.get(
        url,
        data: data,
        queryParameters: params,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      ),
    );
  }

  Future<dynamic> _handleResponseIsPaused(
    Future<Response<dynamic>> task,
  ) async {
    try {
      Response<dynamic> res = await task; // await等待处理 get请求响应结果
      final data = res.data;
      // print(res);
      return data;
    } catch (e) {
      throw Exception(e);
    }
  }

  // 收藏小说请求
  Future<void> dioPut(
    String url, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) {
    return _dio.put(
      url,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  // 删除收藏小说请求
  Future<void> dioDelete(
    String url, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.delete(
      url,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  // 普通post请求
  Future<dynamic> dioPost(
    String url, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) {
    return _dio.post(
      url,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  // 下载小说请求
  Future<void> downloadFile({
    required String url,
    required String fileName,
    String? savePath, // 允许外部指定路径
    void Function(int received, int total)? onReceiveProgress, // 进度回调
  }) async {
    if (kIsWeb) {
      // Web 环境保持不变
      final response = await _dio.get(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      final blob = html.Blob([response.data]);
      final anchor =
          html.AnchorElement(href: html.Url.createObjectUrlFromBlob(blob))
            ..target = 'blank'
            ..download = fileName;
      anchor.click();
      html.Url.revokeObjectUrl(anchor.href!);
    } else {
      // 移动端/桌面端：动态获取下载目录
      String downloadPath;
      if (savePath != null && savePath.isNotEmpty) {
        downloadPath = savePath;
      } else {
        if (Platform.isAndroid) {
          // Android：优先使用公共下载目录
          final directory = await getExternalStorageDirectory();
          if (directory != null) {
            // 外部存储可用，构造下载目录路径
            downloadPath = '${directory.path}/Download';
          } else {
            // 降级使用应用私有目录
            final appDocDir = await getApplicationDocumentsDirectory();
            downloadPath = appDocDir.path;
          }
        } else {
          // iOS/桌面端：使用应用文档目录
          final appDocDir = await getApplicationDocumentsDirectory();
          downloadPath = appDocDir.path;
        }
        // 确保目录存在
        await Directory(downloadPath).create(recursive: true);
      }

      final fullPath = '$downloadPath/$fileName';
      try {
        await _dio.download(
          url,
          fullPath,
          onReceiveProgress: onReceiveProgress,
        );
        ToastUtils2.showToastBottom("$fileName下载完成");
      } catch (e) {
        ToastUtils2.showToastBottom("下载失败: ${e.toString()}");
      }
    }
  }
}

// 单列对象
final dioRequest = DioRequest(); // 实例化, 其他模块可以直接调用
