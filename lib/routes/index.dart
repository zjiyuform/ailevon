// 管理路由
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ailevon/pages/DownloadManager/download_manager_page.dart';
import 'package:ailevon/pages/Login/login.dart';
import 'package:ailevon/pages/WebNovelDetails/web_details_page.dart';
import 'package:ailevon/pages/WenkuNovelDetails/wenku_details_page.dart';
import 'package:ailevon/pages/WenkuSearch/wenkupage.dart';
import 'package:ailevon/pages/main_page.dart';
import 'package:ailevon/pages/WebSearch/webpage.dart';
import 'package:ailevon/stores/theme_controller.dart';

// 获取主题控制器
final ThemeController themeController = Get.find();
// 返回App根级组件
Widget getRootWidget() {
  return Obx(
    () => MaterialApp(
      // 命名路由
      initialRoute: "/",
      routes: getRootRoutes(),
      onGenerateRoute: (settings) {
        // 新增：处理动态路由
        final name = settings.name;
        // 只处理需要解析参数的路由
        if (name != null && name.startsWith("/webnoveldetails")) {
          final uri = Uri.parse(name);
          final provider = uri.queryParameters['provider'];
          final novelId = uri.queryParameters['novelId'];
          // 判断web小说参数
          if (provider != null && novelId != null) {
            //通过构造函数传参
            return MaterialPageRoute(
              // settings 传进去，浏览器地址栏才会更新
              settings: settings,
              builder: (_) =>
                  WebNovelDetailsPage(providerId: provider, novelId: novelId),
            );
          }
        }

        // 判断wenku小说参数
        if (name != null && name.startsWith("/wenkunoveldetails")) {
          final uri = Uri.parse(name);
          final id = uri.queryParameters['id'];
          if (id != null) {
            //通过构造函数传参
            return MaterialPageRoute(
              // settings 传进去，浏览器地址栏才会更新
              settings: settings,
              builder: (_) => WenkuDetailsPage(id: id),
            );
          }
        }

        // 其他路由返回 null，让 routes 映射处理
        return null;
      },
      theme: lightTheme,
      darkTheme: ThemeData.dark().copyWith(
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Colors.green,
          selectionColor: Colors.green,
          selectionHandleColor: Colors.green,
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: Colors.grey),
        ),
      ),
      themeMode: themeController.themeMode.value,
    ),
  );
}

// 返回改App的路由配置
Map<String, Widget Function(BuildContext)> getRootRoutes() {
  return {
    "/": (context) => MainPage(), // 主页路由
    "/login": (context) => LoginPage(), // 登录路由
    "/websearch": (context) => WebSearchPage(), // web小说搜索路由
    "/wenkusearch": (context) => WenkuSearchPage(), // wenku小说搜索路由
    "/downloadmanager": (context) => DownloadManagerPage(), // 下载管理路由
  };
}

// 亮色主题
ThemeData lightTheme = ThemeData(
  scaffoldBackgroundColor: Color(0xFFF5F5F5),
  canvasColor: Color(0xFFF5F5F5),
  appBarTheme: AppBarTheme(
    scrolledUnderElevation: 0,
    backgroundColor: Color(0xFFF5F5F5),
    shadowColor: Color(0xFFF5F5F5),
    surfaceTintColor: Color(0xFFF5F5F5),
  ),
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: Colors.green,
    selectionColor: Colors.green,
    selectionHandleColor: Colors.green,
  ),
  pageTransitionsTheme: const PageTransitionsTheme(
    builders: {
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    },
  ),
  bottomSheetTheme: BottomSheetThemeData(backgroundColor: Color(0xFFF5F5F5)),
  dialogTheme: DialogThemeData(backgroundColor: Color(0xFFF5F5F5)),
  popupMenuTheme: const PopupMenuThemeData(color: Color(0xFFF5F5F5)),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: Colors.black),
  ),
);
