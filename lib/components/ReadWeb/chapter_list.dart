import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:ailevon/stores/chapter_options_controller.dart';
import 'package:ailevon/viewmodels/chapter_node.dart';
import 'package:ailevon/utils/Function/updatetime.dart';

class ChapterList extends StatefulWidget {
  final void Function(String chapterId) jumpToChapter;
  final List<Map<String, dynamic>> toc;
  final int currentChapterIndex; // 当前阅读章节的 globalIndex（从0开始）

  const ChapterList({
    super.key,
    required this.jumpToChapter,
    required this.toc,
    required this.currentChapterIndex,
  });

  @override
  State<ChapterList> createState() => _ChapterListState();
}

class _ChapterListState extends State<ChapterList> {
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  List<VolumeNode> _volumes = [];
  // bool _isReversed = false;
  final ChapterOptionsController _chapterOptionsController =
      Get.find<ChapterOptionsController>();

  // 扁平化后的数据（根据当前展开/折叠状态）
  List<CatalogNode> get _flatList {
    final List<CatalogNode> flat = [];
    for (final volume in _volumes) {
      flat.add(volume); // 卷标题占一个位置
      if (volume.isExpanded) {
        flat.addAll(volume.children); // 展开时才加入子章节
      }
    }
    return flat;
  }

  @override
  void initState() {
    super.initState();
    _parseToc();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _locateToCurrentChapter(),
    );
  }

  /// 解析原始 toc 数据为 Volume/Chapter 模型
  void _parseToc() {
    List<VolumeNode> volumes = [];
    VolumeNode? currentVolume;
    int globalIndex = 0;

    for (var item in widget.toc) {
      final bool isVolume = item['chapterId'] == null;

      if (isVolume) {
        // 遇到卷：保存上一个卷
        if (currentVolume != null) {
          volumes.add(currentVolume);
        }
        // 创建新卷
        currentVolume = VolumeNode(
          id: item['id']?.toString() ?? '',
          titleJp: item['titleJp'] ?? '',
          titleZh: item['titleZh'] ?? '',
          children: [],
        );
      } else {
        // 创建章节
        final chapter = ChapterNode(
          chapterId: item['chapterId'].toString(),
          id: item['id']?.toString() ?? '',
          titleJp: item['titleJp'] ?? '',
          titleZh: item['titleZh'] ?? '',
          globalIndex: globalIndex++,
          createAt: item['createAt'],
        );

        // 确保有卷可放
        if (currentVolume == null) {
          // 创建虚拟卷（用于无卷包裹的章节）
          if (volumes.isEmpty || volumes.last.id != '_virtual_') {
            currentVolume = VolumeNode(
              id: '_virtual_',
              titleJp: '',
              titleZh: '',
              children: [],
            );
            volumes.add(currentVolume);
          } else {
            currentVolume = volumes.last;
          }
        }
        currentVolume.children.add(chapter);
      }
    }

    // 添加最后一个卷
    if (currentVolume != null && !volumes.contains(currentVolume)) {
      volumes.add(currentVolume);
    }

    if (_chapterOptionsController.isReversed.value) {
      volumes = volumes.reversed.toList();
      for (final volume in volumes) {
        volume.children = volume.children.reversed.toList();
      }
    }

    setState(() => _volumes = volumes);
  }

  /// 定位到当前阅读章节
  void _locateToCurrentChapter() {
    // 确保祖先卷是展开的
    for (final volume in _volumes) {
      if (volume.children.any(
        (ch) => ch.globalIndex == widget.currentChapterIndex,
      )) {
        volume.isExpanded = true;
      }
    }
    setState(() {}); // 重建扁平列表

    // 计算目标在扁平列表中的索引
    final targetIndex = _flatList.indexWhere(
      (node) =>
          node is ChapterNode && node.globalIndex == widget.currentChapterIndex,
    );

    if (targetIndex != -1) {
      _itemScrollController.jumpTo(index: targetIndex, alignment: 0.1);
    }
  }

  /// 切换全部展开/折叠
  void _toggleAllExpand() {
    final bool newState = !_volumes.every((v) => v.isExpanded);
    for (final volume in _volumes) {
      volume.isExpanded = newState;
    }
    setState(() {});
  }

  /// 切换正序/倒序
  void _toggleOrder() {
    setState(() {
      _chapterOptionsController.updateReversed();
      _volumes = _volumes.reversed.toList();
      for (final volume in _volumes) {
        volume.children = volume.children.reversed.toList();
      }
    });
    _locateToCurrentChapter();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, sheetScrollController) {
        return Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ScrollablePositionedList.builder(
                itemScrollController: _itemScrollController,
                itemPositionsListener: _itemPositionsListener,
                itemCount: _flatList.length,
                itemBuilder: (context, index) {
                  final node = _flatList[index];
                  if (node is VolumeNode) {
                    return _buildVolumeHeader(node);
                  } else {
                    return _buildChapterTile(node as ChapterNode);
                  }
                },
                // 可在此添加分页加载逻辑（例如接近底部时加载更多数据）
              ),
            ),
          ],
        );
      },
    );
  }

  /// 头部：展开/折叠全部 + 正序/倒序切换
  Widget _buildHeader() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: _toggleAllExpand,
                child: Row(
                  children: _volumes.every((v) => v.isExpanded)
                      ? [const Icon(Icons.expand_less), const Text("折叠")]
                      : [const Icon(Icons.expand_more), const Text("展开")],
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _toggleOrder,
                child: Row(
                  children: _chapterOptionsController.isReversed.value
                      ? [const Icon(Icons.arrow_upward), const Text("倒序")]
                      : [const Icon(Icons.arrow_downward), const Text("正序")],
                ),
              ),
            ],
          ),
          const Divider(),
        ],
      ),
    );
  }

  /// 构建卷头部（替代 ExpansionTile，实现完全懒加载）
  Widget _buildVolumeHeader(VolumeNode volume) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              volume.isExpanded = !volume.isExpanded;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              children: [
                Icon(
                  volume.isExpanded ? Icons.expand_less : Icons.expand_more,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      text: '${volume.titleJp}\n',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      children: [
                        TextSpan(
                          text: volume.titleZh,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // 分割线（卷与第一个章节之间）
        if (volume.isExpanded && volume.children.isNotEmpty)
          const Divider(height: 1, indent: 16, endIndent: 16),
      ],
    );
  }

  /// 构建章节条目
  Widget _buildChapterTile(ChapterNode chapter) {
    final isCurrent = chapter.globalIndex == widget.currentChapterIndex;
    return Column(
      children: [
        ListTile(
          selected: isCurrent,
          selectedTileColor: Colors.green.withValues(alpha: 0.1),
          onTap: () {
            Navigator.pop(context);
            widget.jumpToChapter(chapter.chapterId);
          },
          title: Text.rich(
            TextSpan(
              text: '${chapter.titleJp}\n',
              style: TextStyle(color: isCurrent ? Colors.amber : Colors.green),
              children: [
                TextSpan(
                  text: chapter.titleZh,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          subtitle: Text(
            '[${chapter.globalIndex}] ${chapter.createAt != null ? formartDateHM(chapter.createAt!) : ''}',
          ),
        ),
        const Divider(height: 1, indent: 16, endIndent: 16),
      ],
    );
  }
}
