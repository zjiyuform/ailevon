import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

enum DisplayMode { japanese, chinese, cnFirst, jpFirst }

enum TranslationSource { baidu, youdao, gpt, sakura }

enum BackgroundColorOption { lightYellow, lightGray, lightPurple, darkGray }

class ReadSettingsController extends GetxController {
  final box = GetStorage(); // 持久化存储

  // 响应式变量，UI 自动更新
  final displayMode = DisplayMode.cnFirst.obs;
  final translationSource = TranslationSource.sakura.obs;
  final fontSize = 16.0.obs;
  final lineHeight = 1.5.obs;
  final paragraphSpacing = 0.0.obs;
  final isTraditional = false.obs;
  final bgColorOption = BackgroundColorOption.lightGray.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  void _loadSettings() {
    // 从存储中读取，没有则使用默认值
    displayMode.value = _stringToDisplayMode(
      box.read('displayMode') ?? 'cnFirst',
    );
    translationSource.value = _stringToTranslationSource(
      box.read('translationSource') ?? 'sakura',
    );
    fontSize.value = box.read('fontSize') ?? 16.0;
    lineHeight.value = box.read('lineHeight') ?? 1.5;
    paragraphSpacing.value = box.read("paragraphSpacing") ?? 0.0;
    isTraditional.value = box.read("isTraditional") ?? false;
    bgColorOption.value = _stringToBgColorOption(
      box.read('bgColorOption') ?? 'white',
    );
  }

  // 更新方法，同时写入存储
  void updateDisplayMode(DisplayMode mode) {
    displayMode.value = mode;
    box.write('displayMode', mode.name);
  }

  void updateTranslationSource(TranslationSource source) {
    translationSource.value = source;
    box.write('translationSource', source.name);
  }

  void updateFontSize(double size) {
    fontSize.value = size;
    box.write('fontSize', size);
  }

  void updateLineHeight(double height) {
    lineHeight.value = height;
    box.write('lineHeight', height);
  }

  void updateParagraphSpacing(double spacing) {
    paragraphSpacing.value = spacing;
    box.write('paragraphSpacing', spacing);
  }

  void updateIsTraditional() {
    isTraditional.value = !isTraditional.value;
    box.write('isTraditional', isTraditional.value);
  }

  void updateBgColorOption(BackgroundColorOption option) {
    bgColorOption.value = option;
    box.write('bgColorOption', option.name);
  }

  // 辅助转换函数
  DisplayMode _stringToDisplayMode(String str) {
    return DisplayMode.values.firstWhere(
      (e) => e.name == str,
      orElse: () => DisplayMode.cnFirst,
    );
  }

  TranslationSource _stringToTranslationSource(String str) {
    return TranslationSource.values.firstWhere(
      (e) => e.name == str,
      orElse: () => TranslationSource.sakura,
    );
  }

  BackgroundColorOption _stringToBgColorOption(String str) {
    return BackgroundColorOption.values.firstWhere(
      (e) => e.name == str,
      orElse: () => BackgroundColorOption.lightGray,
    );
  }
}
