import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ailevon/stores/web_download_controller.dart';

class SettingWebDownloadDialog {
  static void show(BuildContext context, {bool isWeb = true}) {
    showDialog(
      context: context,
      builder: (context) => SetDownDialog(isWeb: isWeb),
    );
  }
}

class SetDownDialog extends StatelessWidget {
  final bool isWeb;
  SetDownDialog({super.key, this.isWeb = true});

  // 获取共享的参数
  final controller = Get.find<WebDownloadController>();

  // 1 标题行
  Row _getOneRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("下载设置", style: TextStyle(fontSize: 20)),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  // 单项tagButtonList设计为可共用的方法
  List<Widget> _getTagButtomList({
    required List<String> selectedTag,
    required List<String> selectedName,
    required WebDownloadController wdcontroller,
    required String ctlArg,
    required String defaultArg,
  }) {
    // 直接从响应式变量获取当前选中值
    String currentMode = wdcontroller.webDownload[ctlArg] ?? defaultArg;

    List<Widget> tagButtomList = List.generate(selectedTag.length, (index) {
      // 判断当前索引是否被选中
      bool isSelected = (currentMode == selectedTag[index]);
      return Container(
        padding: const EdgeInsets.all(8),
        margin: EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: GestureDetector(
          onTap: () {
            if (currentMode == selectedTag[index]) return;
            if (ctlArg == "mode") {
              wdcontroller.updateWebDownloadInfo(mode: selectedTag[index]);
            } else if (ctlArg == "translationsMode") {
              wdcontroller.updateWebDownloadInfo(
                translationsMode: selectedTag[index],
              );
            } else if (ctlArg == "type") {
              wdcontroller.updateWebDownloadInfo(type: selectedTag[index]);
            }
            // print(wdcontroller.webDownload);
          },
          child: Text(
            selectedName[index],
            style: TextStyle(
              fontSize: 18,
              color: isSelected ? Colors.white : null,
            ),
          ),
        ),
      );
    });

    return tagButtomList;
  }

  // 2 语言选择行
  Widget _getTwoRow() {
    return Row(
      children: [
        Text("语言", style: TextStyle(fontSize: 16, color: Colors.grey[600])),
        const SizedBox(width: 10),
        Row(
          children: _getTagButtomList(
            selectedTag: ["zh", "zh-jp", "jp-zh"],
            selectedName: ["中文", "中日", "日中"],
            wdcontroller: controller,
            ctlArg: "mode",
            defaultArg: "zh",
          ),
        ),
      ],
    );
  }

  // 3 翻译类型行
  Widget _getThreeRow() {
    return Row(
      children: [
        Text("翻译", style: TextStyle(fontSize: 16, color: Colors.grey[600])),
        const SizedBox(width: 10),
        // 调用获取tagButtonList方法
        Row(
          children: _getTagButtomList(
            selectedTag: ["priority", "parallel"],
            selectedName: ["优先", "并列"],
            wdcontroller: controller,
            ctlArg: "translationsMode",
            defaultArg: "priority",
          ),
        ),
      ],
    );
  }

  // 4 机翻类型列表行
  Widget _getFourRow() {
    List<String> selectedTags = ["baidu", "youdao", "gpt", "sakura"];
    List<String> selectedName = ["百度", "有道", "GPT", "Sakura"];
    // 直接从响应式变量获取当前选中值
    List<String> currentTranslations = List<String>.from(
      controller.webDownload["translations"] ??
          ['sakura', 'gpt', 'youdao', 'baidu'],
    );

    List<Widget> tagButtomList = List.generate(selectedTags.length, (index) {
      var isSelected = currentTranslations.contains(
        selectedTags[index],
      ); // 判断是否选中
      return GestureDetector(
        onTap: () {
          if (isSelected) {
            currentTranslations.remove(selectedTags[index]);
            controller.updateWebDownloadInfo(translations: currentTranslations);
          } else {
            currentTranslations.add(selectedTags[index]);
            controller.updateWebDownloadInfo(translations: currentTranslations);
          }
          // print(controller.webDownload);
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.green : null,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 标签名称
              Text(
                selectedName[index],
                style: TextStyle(
                  fontSize: 18,
                  color: isSelected ? Colors.white : null,
                ),
                textAlign: TextAlign.center,
              ),
              // 序号/状态
              Text(
                "[${isSelected ? currentTranslations.indexOf(selectedTags[index]) + 1 : "x"}]",
                style: TextStyle(
                  fontSize: 14,
                  color: isSelected ? Colors.white : null,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    });

    return Wrap(spacing: 8, runSpacing: 8, children: tagButtomList);
  }

  // 5 下载文件类型行
  Widget _getFiveRow() {
    return Row(
      children: [
        Text("文件", style: TextStyle(fontSize: 16, color: Colors.grey[600])),
        const SizedBox(width: 10),
        // 调用获取tagButtonList方法
        Row(
          children: _getTagButtomList(
            selectedTag: ["epub", "txt"],
            selectedName: ["EPUB", "TXT"],
            wdcontroller: controller,
            ctlArg: "type",
            defaultArg: "epub",
          ),
        ),
      ],
    );
  }

  // 6 是否中文名切换行
  Widget _getSixRow() {
    // 直接从响应式变量获取当前选中值
    String currentDFT = controller.webDownload["downloadFilenameType"] ?? "zh";
    // 开关状态： downloadFilenameType为"zh"时, true=开启（绿色）,不为时false=关闭（灰色）
    bool isChineseFileName = currentDFT == "zh";

    return Row(
      children: [
        Text("中文文件名", style: TextStyle(fontSize: 16, color: Colors.grey[600])),
        const SizedBox(width: 10),
        // 调用获取tagButtonList方法
        // 右侧开关
        Switch(
          // 绑定状态
          value: isChineseFileName,
          // 状态变化回调
          onChanged: (value) {
            controller.updateWebDownloadInfo(
              downloadFilenameType: value ? "zh" : "jp",
            );
            // print(controller.webDownload);
          },
          // 开启状态的轨道颜色
          activeTrackColor: Colors.green,
          // 开启状态的滑块颜色
          activeThumbColor: Colors.white,
          // 关闭状态的轨道颜色
          inactiveTrackColor: Colors.grey[300],
          // 关闭状态的滑块颜色
          inactiveThumbColor: Colors.white,
          // 去掉默认的水波纹/高亮效果，更贴近原生UI
          splashRadius: 0,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      constraints: const BoxConstraints(maxWidth: 560),
      child: Obx(
        () => Container(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _getOneRow(context),
              const SizedBox(height: 16),
              _getTwoRow(),
              const SizedBox(height: 16),
              // 继续添加其他设置项，从 controller.webDownload 读取
              _getThreeRow(),
              const SizedBox(height: 16),
              _getFourRow(),
              const SizedBox(height: 16),
              isWeb
                  ? Column(
                      children: [_getFiveRow(), const SizedBox(height: 16)],
                    )
                  : SizedBox.shrink(),
              isWeb
                  ? Column(children: [_getSixRow(), const SizedBox(height: 16)])
                  : SizedBox.shrink(),
              Text(
                "# 某些EPUB阅读器无法正确显示日文段落的浅色字体",
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              isWeb
                  ? SizedBox.shrink()
                  : Text(
                      "# 文库下载设置复用web下载设置",
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
