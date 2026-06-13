// 需要用到pageNumber时使用
class WebPageJson {
  List<WebNovelItem> items;
  int pageNumber;
  WebPageJson({required this.items, required this.pageNumber});
  factory WebPageJson.fromJSON(Map<String, dynamic> json) {
    return WebPageJson(
      items: (json["items"] as List? ?? [])
          .map((item) => WebNovelItem.fromJSON(item as Map<String, dynamic>))
          .toList(),
      pageNumber: (json["pageNumber"]) ?? -1,
    );
  }
}

// 声明一个 web 主页 的web小说项类(不需要pageNumber时可直接使用)
class WebNovelItem {
  String providerId;
  String novelId;
  String titleJp;
  String titleZh;
  String type;
  List<String> attentions;
  List<String> keywords;
  int? lastReadAt;
  int total;
  int jp;
  int baidu;
  int youdao;
  int gpt;
  int sakura;
  int updateAt;
  WebNovelItem({
    required this.providerId,
    required this.novelId,
    required this.titleJp,
    required this.titleZh,
    required this.type,
    required this.attentions,
    required this.keywords,
    this.lastReadAt,
    required this.total,
    required this.jp,
    required this.baidu,
    required this.youdao,
    required this.gpt,
    required this.sakura,
    required this.updateAt,
  });
  // 拓展一个工厂函数 一般用factory来声明 一般用来创建实例对象
  factory WebNovelItem.fromJSON(Map<String, dynamic> item) {
    // 必须返回一个WebNovelItem对象
    return WebNovelItem(
      providerId: item["providerId"] ?? "",
      novelId: item["novelId"] ?? "",
      titleJp: item["titleJp"] ?? "",
      titleZh: item["titleZh"] ?? "",
      type: item["type"] ?? "",
      attentions: item["attentions"]?.cast<String>() ?? [],
      keywords: item["keywords"]?.cast<String>() ?? [],
      lastReadAt: item["lastReadAt"],
      total: item["total"] ?? -1,
      jp: item["jp"] ?? -1,
      baidu: item["baidu"] ?? -1,
      youdao: item["youdao"] ?? -1,
      gpt: item["gpt"] ?? -1,
      sakura: item["sakura"] ?? -1,
      updateAt: item["updateAt"] ?? -1,
    );
  }
}
