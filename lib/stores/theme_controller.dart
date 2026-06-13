import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {
  final box = GetStorage();
  final Rx<ThemeMode> themeMode = ThemeMode.light.obs; // 默认亮色模式

  @override
  void onInit() {
    super.onInit();
    String stored = box.read('themeMode') ?? 'light';
    themeMode.value = _stringToThemeMode(stored);
  }

  void _saveThemeMode(ThemeMode mode) {
    String str = mode == ThemeMode.light ? 'light' : 'dark';
    box.write('themeMode', str);
  }

  ThemeMode _stringToThemeMode(String str) {
    return str == 'dark' ? ThemeMode.dark : ThemeMode.light;
  }

  void setDarkMode() {
    themeMode.value = ThemeMode.dark;
    _saveThemeMode(ThemeMode.dark);
  }

  void setLightMode() {
    themeMode.value = ThemeMode.light;
    _saveThemeMode(ThemeMode.light);
  }

  // 可选：一键切换
  void toggleTheme() {
    if (themeMode.value == ThemeMode.light) {
      setDarkMode();
    } else {
      setLightMode();
    }
  }
}
