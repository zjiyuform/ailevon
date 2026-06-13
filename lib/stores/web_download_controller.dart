import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/* wenku下载复用web_download设置 */

class WebDownloadController extends GetxController {
  final webDownload = {}.obs;
  final box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  void _loadSettings() {
    // 同步读取，无需 await
    webDownload['mode'] = box.read('mode') ?? 'zh';
    webDownload['translationsMode'] =
        box.read('translationsMode') ?? 'priority';
    webDownload['translations'] =
        box.read('translations') ?? ['sakura', 'gpt', 'youdao', 'baidu'];
    webDownload['type'] = box.read('type') ?? 'epub';
    webDownload['downloadFilenameType'] =
        box.read('downloadFilenameType') ?? 'zh';
  }

  void updateWebDownloadInfo({
    String? mode,
    String? translationsMode,
    List<String>? translations,
    String? type,
    String? downloadFilenameType,
  }) {
    if (mode != null) {
      webDownload['mode'] = mode;
      box.write('mode', mode);
    }
    if (translationsMode != null) {
      webDownload['translationsMode'] = translationsMode;
      box.write('translationsMode', translationsMode);
    }
    if (translations != null) {
      webDownload['translations'] = translations;
      box.write('translations', translations);
    }
    if (type != null) {
      webDownload['type'] = type;
      box.write('type', type);
    }
    if (downloadFilenameType != null) {
      webDownload['downloadFilenameType'] = downloadFilenameType;
      box.write('downloadFilenameType', downloadFilenameType);
    }
  }
}
