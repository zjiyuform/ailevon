// ignore_for_file: invalid_use_of_protected_member

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ReadPositionController extends GetxController {
  final box = GetStorage('read_position');
  final readPositions = {}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadReadPositions();
  }

  void _loadReadPositions() {
    // 从存储中读取，没有则使用默认值
    readPositions.value = box.read('readPositions') ?? {};
  }

  // 更新位置储存
  void updateReadPositions(String webInfo, Map chapterInfo) {
    readPositions[webInfo] = chapterInfo;
    box.write('readPositions', readPositions.value);
  }

  // 删除位置储存
  void removeReadPositions(String webInfo) {
    readPositions.remove(webInfo);
    box.write('readPositions', readPositions.value);
  }

  // 清空位置储存
  void clearReadPositions() {
    readPositions.clear();
    box.write('readPositions', readPositions.value);
  }
}
