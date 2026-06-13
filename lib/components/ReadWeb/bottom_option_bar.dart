import 'package:flutter/material.dart';
import 'package:ailevon/components/ReadWeb/chapter_list.dart';
import 'package:ailevon/utils/widget/setting_read_show_panel.dart';

class BottomOptionBar extends StatefulWidget {
  final Function? changeChapter; // 上下章节
  final Function? cancelAutoHide;
  final Function? jumpToChapter; // 列表跳转章节
  final List<Map<String, dynamic>>? toc;
  final List? adress;
  final int? currentIndex; // 当前阅读章节索引
  final Color? color;
  const BottomOptionBar({
    super.key,
    this.changeChapter,
    this.cancelAutoHide,
    this.jumpToChapter,
    this.toc,
    this.adress,
    this.currentIndex,
    this.color,
  });

  @override
  State<BottomOptionBar> createState() => _BottomOptionBarState();
}

class _BottomOptionBarState extends State<BottomOptionBar> {
  //
  // 显示章节列表弹窗（简单示例）
  void _showChapterList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ChapterList(
        // 列表页点击跳转函数
        jumpToChapter: widget.jumpToChapter! as Function(String),
        toc: widget.toc!,
        currentChapterIndex: widget.currentIndex!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: widget.color,
        boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black12)],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.skip_previous),
              onPressed: () {
                widget.changeChapter!('prev');
                widget.cancelAutoHide!();
              },
              tooltip: '上一章',
            ),
            IconButton(
              icon: const Icon(Icons.list),
              onPressed: () {
                _showChapterList();
              },
              tooltip: '章节列表',
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                SettingReadShowPanel.showSettingsPanel(context);
              },
              tooltip: '设置',
            ),
            IconButton(
              icon: const Icon(Icons.skip_next),
              onPressed: () {
                widget.changeChapter!('next');
                widget.cancelAutoHide!();
              },
              tooltip: '下一章',
            ),
          ],
        ),
      ),
    );
  }
}
