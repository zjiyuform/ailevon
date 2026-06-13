import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ailevon/stores/read_settings_controller.dart';

class SettingReadShowPanel {
  static void showSettingsPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) => ReadSettingPanel(),
    );
  }
}

class ReadSettingPanel extends StatefulWidget {
  const ReadSettingPanel({super.key});

  @override
  State<ReadSettingPanel> createState() => _ReadSettingPanelState();
}

class _ReadSettingPanelState extends State<ReadSettingPanel> {
  final ReadSettingsController settings = Get.find<ReadSettingsController>();

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setBottomSheetState) {
        return Container(
          padding: EdgeInsets.all(20),
          child: ListView(
            // ✅ 改用 ListView
            shrinkWrap: true, // 让 ListView 高度由内容决定，避免与父容器冲突
            children: [
              ListTile(
                leading: Icon(Icons.view_agenda),
                title: Text('显示模式'),
                trailing: DropdownButton<DisplayMode>(
                  value: settings.displayMode.value,
                  items: [
                    DropdownMenuItem(
                      value: DisplayMode.japanese,
                      child: Text('日文'),
                    ),
                    DropdownMenuItem(
                      value: DisplayMode.chinese,
                      child: Text('中文'),
                    ),
                    DropdownMenuItem(
                      value: DisplayMode.cnFirst,
                      child: Text('中日'),
                    ),
                    DropdownMenuItem(
                      value: DisplayMode.jpFirst,
                      child: Text('日中'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setBottomSheetState(
                        () => settings.updateDisplayMode(value),
                      );
                    }
                  },
                ),
              ),
              ListTile(
                leading: Icon(Icons.translate),
                title: Text('翻译来源'),
                trailing: DropdownButton<TranslationSource>(
                  value: settings.translationSource.value,
                  items: [
                    DropdownMenuItem(
                      value: TranslationSource.baidu,
                      child: Text('百度翻译'),
                    ),
                    DropdownMenuItem(
                      value: TranslationSource.youdao,
                      child: Text('有道翻译'),
                    ),
                    DropdownMenuItem(
                      value: TranslationSource.gpt,
                      child: Text('GPT翻译'),
                    ),
                    DropdownMenuItem(
                      value: TranslationSource.sakura,
                      child: Text('sakura翻译'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setBottomSheetState(
                        () => settings.updateTranslationSource(value),
                      );
                    }
                  },
                ),
              ),
              ListTile(
                leading: Icon(Icons.text_fields),
                title: Text('字体大小'),
                trailing: Text('${settings.fontSize.value.round()}'),
              ),
              Slider(
                value: settings.fontSize.value,
                min: 12,
                max: 30,
                divisions: 18,
                activeColor: Colors.green, // 已滑过部分 → 绿色
                inactiveColor: Colors.green[100], // 未滑过部分 → 浅绿
                thumbColor: Colors.green, // 滑块圆点 → 绿色
                label: settings.fontSize.value.round().toString(),
                onChanged: (value) {
                  setBottomSheetState(() => settings.updateFontSize(value));
                },
              ),
              ListTile(
                leading: Icon(Icons.height),
                title: Text('行间距'),
                trailing: Text(settings.lineHeight.value.toStringAsFixed(1)),
              ),
              Slider(
                value: settings.lineHeight.value,
                min: 1.0,
                max: 2.5,
                divisions: 15,
                activeColor: Colors.green, // 已滑过部分 → 绿色
                inactiveColor: Colors.green[100], // 未滑过部分 → 浅绿
                thumbColor: Colors.green, // 滑块圆点 → 绿色
                label: settings.lineHeight.value.toStringAsFixed(1),
                onChanged: (value) {
                  setBottomSheetState(() => settings.updateLineHeight(value));
                },
              ),
              ListTile(
                leading: Icon(Icons.format_line_spacing),
                title: Text('段间距'),
                trailing: Text('${settings.paragraphSpacing.value.round()}'),
              ),
              Slider(
                value: settings.paragraphSpacing.value,
                min: 0,
                max: 50,
                divisions: 10,
                activeColor: Colors.green, // 已滑过部分 → 绿色
                inactiveColor: Colors.green[100], // 未滑过部分 → 浅绿
                thumbColor: Colors.green, // 滑块圆点 → 绿色
                label: settings.paragraphSpacing.value.round().toString(),
                onChanged: (value) {
                  setBottomSheetState(
                    () => settings.updateParagraphSpacing(value),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.palette),
                title: Text('背景颜色'),
                trailing: DropdownButton<BackgroundColorOption>(
                  value: settings.bgColorOption.value,
                  items: [
                    DropdownMenuItem(
                      value: BackgroundColorOption.lightGray,
                      child: Text('浅灰'),
                    ),
                    DropdownMenuItem(
                      value: BackgroundColorOption.lightYellow,
                      child: Text('浅黄'),
                    ),
                    DropdownMenuItem(
                      value: BackgroundColorOption.lightPurple,
                      child: Text('淡紫'),
                    ),
                    DropdownMenuItem(
                      value: BackgroundColorOption.darkGray,
                      child: Text('深灰'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setBottomSheetState(
                        () => settings.updateBgColorOption(value),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
