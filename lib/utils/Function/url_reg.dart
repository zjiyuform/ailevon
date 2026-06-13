/// 解析小说网站 URL，返回 (平台标识, 作品ID) 或 null（无法匹配）
/// 支持以下网站：
/// - kakuyomu.jp/works/{id}
/// - ncode.syosetu.com/{id}
/// - pixiv.net/novel/series/{id}
/// - novelup.plus/story/{id}
/// - syosetu.org/novel/{id} → 平台标识为 "hameln"
/// - alphapolis.co.jp/novel/{id1}/{id2} → 作品ID为 "id1-id2"
({String platform, String id})? parseNovelUrl(String url) {
  // 定义规则列表：正则表达式，平台名称，ID 捕获组描述
  final rules = [
    (
      pattern: RegExp(r'kakuyomu\.jp/works/(\d+)', caseSensitive: false),
      platform: 'kakuyomu',
      idExtractor: (Match m) => m.group(1)!,
    ),
    (
      pattern: RegExp(r'ncode\.syosetu\.com/([a-z0-9]+)', caseSensitive: false),
      platform: 'syosetu',
      idExtractor: (Match m) => m.group(1)!,
    ),
    (
      pattern: RegExp(r'pixiv\.net/novel/series/(\d+)', caseSensitive: false),
      platform: 'pixiv',
      idExtractor: (Match m) => m.group(1)!,
    ),
    (
      pattern: RegExp(r'novelup\.plus/story/(\d+)', caseSensitive: false),
      platform: 'novelup',
      idExtractor: (Match m) => m.group(1)!,
    ),
    (
      pattern: RegExp(r'syosetu\.org/novel/(\d+)', caseSensitive: false),
      platform: 'hameln', // 特殊映射
      idExtractor: (Match m) => m.group(1)!,
    ),
    (
      pattern: RegExp(
        r'alphapolis\.co\.jp/novel/(\d+)/(\d+)',
        caseSensitive: false,
      ),
      platform: 'alphapolis',
      idExtractor: (Match m) => '${m.group(1)}-${m.group(2)}',
    ),
  ];

  for (final rule in rules) {
    final match = rule.pattern.firstMatch(url);
    if (match != null) {
      return (platform: rule.platform, id: rule.idExtractor(match));
    }
  }
  return null;
}
