import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ailevon/routes/index.dart';

import 'stores/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //  初始化 GetStorage.init()
  await GetStorage.init();
  await GetStorage.init('read_position');
  Get.put(ThemeController());
  // runApp 启动应用
  runApp(getRootWidget());
}
