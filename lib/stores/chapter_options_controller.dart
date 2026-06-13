import 'package:get/get.dart';

class ChapterOptionsController extends GetxController {
  final isReversed = false.obs;
  // 设计更新正反序设置的方法
  void updateReversed() {
    isReversed.value = !isReversed.value;
  }

  void reset() {
    isReversed.value = false;
  }
}
