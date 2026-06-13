/// 将混合自定义语法的文本转换为纯文本
/// 支持：
/// - **粗体** → 粗体
/// - *斜体* → 斜体
/// - ~~删除线~~ → 删除线
/// - [链接文字](url) → 链接文字 (url)
/// - !!剧透!! → 剧透
/// - ::: star (可选的带符号数字) → 评分：x.x分（数字可为负数，默认为0）
/// - ::: details 标题 ... ::: → 只保留内部文本
String parseToPlainText(String input) {
  String result = input;

  // 1. 处理折叠块（多行，优先处理避免干扰内联标记）
  result = result.replaceAllMapped(
    RegExp(r'::: details .+?\n(.*?)\n:::', dotAll: true),
    (m) => m[1]!.trim(),
  );

  // 2. 星级评分：支持可选数字（整数或小数，可带负号），默认为0
  result = result.replaceAllMapped(RegExp(r'::: star\s*(-?\d+(?:\.\d+)?)?'), (
    m,
  ) {
    String raw = m[1] ?? '';
    double rating;
    if (raw.isEmpty) {
      rating = 0.0;
    } else {
      rating = double.tryParse(raw) ?? 0.0;
    }
    return '⭐评分：${rating.toStringAsFixed(1)}分⭐';
  });

  // 3. 剧透
  result = result.replaceAllMapped(RegExp(r'!!(.*?)!!'), (m) => m[1]!);

  // 4. 链接
  result = result.replaceAllMapped(
    RegExp(r'\[(.*?)\]\((.*?)\)'),
    (m) => '${m[1]} (${m[2]})',
  );

  // 5. 粗体
  result = result.replaceAllMapped(RegExp(r'\*\*(.*?)\*\*'), (m) => m[1]!);

  // 6. 斜体
  result = result.replaceAllMapped(RegExp(r'\*(.*?)\*'), (m) => m[1]!);

  // 7. 删除线
  result = result.replaceAllMapped(RegExp(r'~~(.*?)~~'), (m) => m[1]!);

  return result.trim();
}

// 测试
// void main() {
//   String text =
//       '评分示例：::: star 4.5，默认 ::: star，负数 ::: star -1.2，整数 ::: star -3。'
//       '**粗体** *斜体* ~~删除~~ [链接](url) !!剧透!!';
//   print(parseToPlainText(text));
//   // 输出：评分示例：评分：4.5分，默认 评分：0.0分，负数 评分：-1.2分，整数 评分：-3.0分。粗体 斜体 删除 链接 (url) 剧透
// }
