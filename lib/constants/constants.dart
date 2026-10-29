// ignore_for_file: constant_identifier_names

// 定义全局常量
class GlobalConstants {
  static const String BASE_URL = "https://n.novelia.cc"; // 基础地址
  static const String FORUM_URL = "https://forum.novelia.cc"; // forum/comment地址
  static const int TIME_OUT = 10; // 超时时间
  // static const String SUCCESS_CODE = "";  // 成功状态
}

// 定义存放请求地址接口的常量
class HttpConstants {
  static const String NOVEL_WEB = "/api/novel";
  static const String NOVEL_WENKU = "/api/wenku";
  static const String FAVORED_WEB = "/api/user/favored-web/default";
  static const String FAVORED_WENKU = "/api/user/favored-wenku/default";
  static const String READHISTORY = "/api/user/read-history";
  static const String COMMENTS = "/api/v1/external/comment/novel";
}
