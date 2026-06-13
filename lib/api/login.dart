import 'package:dio/dio.dart';
import 'package:ailevon/stores/token_manager.dart';
import 'package:ailevon/utils/dio_reqeust.dart';
import 'package:ailevon/viewmodels/user.dart';

Future<UserInfo> loginAPI(Map<String, dynamic> data) async {
  return UserInfo.fromJSON(
    await dioRequest.loginInfoPost(
      "https://auth.novelia.cc/api/v1/auth/login",
      data: data,
    ),
  );
}

Future<UserInfo> refreshLoginIofoAPI() async {
  // 获取之前保存的 refresh-token 字符串
  final refreshToken = await tokenManager.getRefreshToken();

  // 构建 Cookie 头（只携带 refresh-token）
  Map<String, String>? headers;
  if (refreshToken != null && refreshToken.isNotEmpty) {
    headers = {'Cookie': 'refresh-token=$refreshToken'};
  }

  // 调用 DioRequest 的 post 方法，传入自定义 Options
  final responseData = await dioRequest.loginInfoPost(
    "https://auth.novelia.cc/api/v1/auth/refresh?app=n",
    options: headers != null ? Options(headers: headers) : null,
  );

  // responseData 是 _handleResponsePost 处理后的数据（Map 结构，包含 token 等）
  return UserInfo.fromJSON(responseData);
}
