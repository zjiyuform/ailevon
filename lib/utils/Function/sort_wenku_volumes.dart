/// 通用版 volumeJp 排序
/// - [volumes] 原始文件列表
/// - [title] 当非 null 时，只保留 volumeId 中包含该标题的条目
/// - [specialKeywords] 自定义特典/番外关键词（不传则使用默认列表）
List<Map<String, dynamic>> sortVolumesDetailed(
  List<Map<String, dynamic>> volumes, {
  String? title,
  List<String>? specialKeywords,
}) {
  // 全角数字转半角
  String toHalfWidth(String str) {
    return str.replaceAllMapped(RegExp(r'[０-９]'), (match) {
      return String.fromCharCode(match.group(0)!.codeUnitAt(0) - 0xFEE0);
    });
  }

  // 默认特殊关键词（可自行扩展）
  final defaultSpecial = ['SS', '小冊子', 'ショートストーリー', '短編', 'とらのあな'];
  final specials = specialKeywords ?? defaultSpecial;

  /// 从 volumeId 中提取卷号（取文件名中最后一个整数或小数）
  /// 返回 null 表示完全没有数字
  double? extractVolumeNumber(String volumeId) {
    // 去掉扩展名
    final name = volumeId.lastIndexOf('.') > 0
        ? volumeId.substring(0, volumeId.lastIndexOf('.'))
        : volumeId;
    // 匹配整数或小数（兼容全角小数点）
    final regex = RegExp(r'([0-9０-９]+(?:[．.][0-9０-９]+)?)');
    final matches = regex.allMatches(name).toList();
    if (matches.isEmpty) return null;
    // 取最后一个匹配（通常是真正的卷号）
    final lastNumStr = matches.last.group(1)!;
    final numStr = toHalfWidth(lastNumStr).replaceAll('．', '.');
    return double.tryParse(numStr);
  }

  // 构建排序键（Comparable 列表）
  List<Comparable> makeKey(Map<String, dynamic> item) {
    final vid = item['volumeId'] as String;
    final num = extractVolumeNumber(vid);

    if (num == null) {
      // 完全没有数字：判断是否为特典
      final isSpecial = specials.any((kw) => vid.contains(kw));
      if (isSpecial) {
        // 纯特典/活动文件，沉底
        return [double.infinity, 0, vid];
      } else {
        // 无数字的普通卷 → 视为第 1 卷
        return [1.0, 0, vid];
      }
    }

    // 有数字时，优先级区分正片与特典
    int priority = 0;
    if (specials.any((kw) => vid.contains(kw))) {
      priority = 2; // 特典/番外排在正片后面
    }

    return [num, priority, vid];
  }

  // ---------- 筛选 ----------
  var list = volumes;
  if (title != null && title.isNotEmpty) {
    final escapedTitle = RegExp.escape(title);
    final titleRegex = RegExp(escapedTitle);
    list = volumes
        .where((v) => titleRegex.hasMatch(v['volumeId'] as String))
        .toList();
  }

  // ---------- 排序 ----------
  final sorted = List<Map<String, dynamic>>.from(list);
  sorted.sort((a, b) {
    final aKey = makeKey(a);
    final bKey = makeKey(b);
    for (int i = 0; i < aKey.length && i < bKey.length; i++) {
      final cmp = (aKey[i]).compareTo(bKey[i]);
      if (cmp != 0) return cmp;
    }
    return 0;
  });

  return sorted;
}
