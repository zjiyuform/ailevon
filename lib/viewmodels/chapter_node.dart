/// 目录节点基类
abstract class CatalogNode {
  final String id;
  final String titleJp;
  final String titleZh;

  CatalogNode({required this.id, required this.titleJp, required this.titleZh});
}

/// 卷（可折叠的父节点）
class VolumeNode extends CatalogNode {
  List<ChapterNode> children;
  bool isExpanded;

  VolumeNode({
    required super.id,
    required super.titleJp,
    required super.titleZh,
    required this.children,
    this.isExpanded = true, // 默认展开
  });
}

/// 章（叶子节点）
class ChapterNode extends CatalogNode {
  final String chapterId;
  final int globalIndex; // 全局章节序号（用于显示）
  final int? createAt;

  ChapterNode({
    required this.chapterId,
    required super.id,
    required super.titleJp,
    required super.titleZh,
    required this.globalIndex,
    this.createAt,
  });
}
