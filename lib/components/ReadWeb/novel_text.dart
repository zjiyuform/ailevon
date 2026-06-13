import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ailevon/stores/read_settings_controller.dart';
import 'package:ailevon/utils/chinese_tw_converter.dart';
import 'package:ailevon/viewmodels/webread.dart';

class NovelText extends StatefulWidget {
  final NovelData novelData;
  final ScrollController? scrollController;
  const NovelText({super.key, required this.novelData, this.scrollController});

  @override
  State<NovelText> createState() => _NovelTextState();
}

class _NovelTextState extends State<NovelText> {
  // 获取控制器（单例）
  final ReadSettingsController settings = Get.find<ReadSettingsController>();

  // 获取章节标题方法
  Widget _buildChapterTitleWidget() {
    final isDark =
        settings.bgColorOption.value == BackgroundColorOption.darkGray;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Column(
        children: [
          Text(
            widget.novelData.titleJp,
            style: TextStyle(
              fontSize: settings.fontSize.value + 4,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          Text(
            settings.isTraditional.value
                ? ChineseTWConverter.convertSync(widget.novelData.titleZh)
                : widget.novelData.titleZh,
            style: TextStyle(
              fontSize: settings.fontSize.value + 4,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.grey[300] : Colors.grey[600],
            ),
          ),
          const Divider(height: 20, thickness: 1),
        ],
      ),
    );
  }

  List<String>? _getChineseParagraphs() {
    List<String>? target;
    switch (settings.translationSource.value) {
      case TranslationSource.sakura:
        target = widget.novelData.sakuraParagraphs;
        break;
      case TranslationSource.baidu:
        target = widget.novelData.baiduParagraphs;
        break;
      case TranslationSource.youdao:
        target = widget.novelData.youdaoParagraphs;
        break;
      case TranslationSource.gpt:
        target = widget.novelData.gptParagraphs;
        break;
    }
    return target;
  }

  // 获取翻译不存在时提示组件方法
  Widget _nonTranInfo() {
    String tranName = "";
    switch (settings.translationSource.value) {
      case TranslationSource.sakura:
        if (widget.novelData.sakuraParagraphs == null) {
          tranName = "Sakura翻译不存在";
        }
        break;
      case TranslationSource.baidu:
        if (widget.novelData.baiduParagraphs == null) {
          tranName = "百度翻译不存在";
        }
        break;

      case TranslationSource.youdao:
        if (widget.novelData.youdaoParagraphs == null) {
          tranName = "有道翻译不存在";
        }
        break;

      case TranslationSource.gpt:
        if (widget.novelData.gptParagraphs == null) {
          tranName = "GPT翻译不存在";
        }
        break;
    }

    return tranName.isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tranName,
                style: TextStyle(color: Colors.grey[600], fontSize: 18),
              ),
              const SizedBox(height: 10),
            ],
          )
        : const SizedBox.shrink();
  }

  // 获取段落组件列表方法
  List<Widget> _buildParagraphs() {
    final jpList = widget.novelData.paragraphs;
    final cnList = _getChineseParagraphs();
    if (jpList.isEmpty) return [];

    final int len = cnList == null
        ? jpList.length
        : (jpList.length < cnList.length ? jpList.length : cnList.length);
    if (len == 0) return [];

    final List<Widget> widgets = [];
    for (int i = 0; i < len; i++) {
      final jpText = jpList[i];
      final cnText = cnList?[i] ?? '';
      switch (settings.displayMode.value) {
        case DisplayMode.japanese:
          if (jpText.isNotEmpty) {
            widgets.add(_buildTextWidget(jpText));
            widgets.add(SizedBox(height: settings.paragraphSpacing.value));
          }
          break;
        case DisplayMode.chinese:
          if (cnText.isNotEmpty) {
            widgets.add(
              _buildTextWidget(
                settings.isTraditional.value
                    ? ChineseTWConverter.convertSync(cnText)
                    : cnText,
              ),
            );
            widgets.add(SizedBox(height: settings.paragraphSpacing.value));
          }

          break;
        case DisplayMode.jpFirst:
          if (jpText.isNotEmpty) {
            widgets.add(_buildTextWidget(jpText, isTranslation: true));
          }
          if (cnText.isNotEmpty) {
            widgets.add(
              _buildTextWidget(
                settings.isTraditional.value
                    ? ChineseTWConverter.convertSync(cnText)
                    : cnText,
              ),
            );
            widgets.add(SizedBox(height: settings.paragraphSpacing.value));
          }
          break;
        case DisplayMode.cnFirst:
          if (cnText.isNotEmpty) {
            widgets.add(
              _buildTextWidget(
                settings.isTraditional.value
                    ? ChineseTWConverter.convertSync(cnText)
                    : cnText,
              ),
            );
          }
          if (jpText.isNotEmpty) {
            widgets.add(_buildTextWidget(jpText, isTranslation: true));
            widgets.add(SizedBox(height: settings.paragraphSpacing.value));
          }
          break;
      }
    }
    return widgets;
  }

  // 返回文本组件方法
  Widget _buildTextWidget(String text, {bool isTranslation = false}) {
    final isDark =
        settings.bgColorOption.value == BackgroundColorOption.darkGray;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: settings.fontSize.value,
          height: settings.lineHeight.value,
          color: isTranslation
              ? Colors.grey[500]
              : isDark
              ? Colors.grey[300]
              : Colors.black,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return ListView(
        controller: widget.scrollController,
        physics: const AlwaysScrollableScrollPhysics(), // 保持垂直滚动
        scrollDirection: Axis.vertical,
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: 100,
        ),
        children: [
          _buildChapterTitleWidget(),
          if (settings.displayMode.value != DisplayMode.japanese)
            _nonTranInfo(),
          ..._buildParagraphs(),
        ],
      );
    });
  }
}
