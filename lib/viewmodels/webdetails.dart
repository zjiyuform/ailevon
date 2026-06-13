// 声明一个 webdetails 主页 的webdetails小说项类
class WebNovelDetails {
  String? wenkuId;
  String titleJp;
  String titleZh;
  List<Map<String, dynamic>> authors;
  String type;
  List<String> attentions;
  List<String> keywords;
  int points;
  int totalCharacters;
  String introductionJp;
  String introductionZh;
  Map<String, dynamic> glossary;
  List<Map<String, dynamic>> toc;
  int visited;
  int syncAt;
  String? favored;
  String? lastReadChapterId;
  int jp;
  int baidu;
  int youdao;
  int gpt;
  int sakura;
  WebNovelDetails({
    this.wenkuId,
    this.titleJp = "",
    this.titleZh = "",
    this.authors = const [],
    this.type = "",
    this.attentions = const [],
    this.keywords = const [],
    this.points = -1,
    this.totalCharacters = -1,
    this.introductionJp = "",
    this.introductionZh = "",
    this.glossary = const {},
    this.toc = const [],
    this.visited = -1,
    this.syncAt = -1,
    this.favored,
    this.lastReadChapterId,
    this.jp = -1,
    this.baidu = -1,
    this.youdao = -1,
    this.gpt = -1,
    this.sakura = -1,
  });
  // 拓展一个工厂函数 一般用factory来声明 一般用来创建实例对象
  factory WebNovelDetails.fromJSON(Map<String, dynamic> item) {
    // 必须返回一个WebNovelItem对象
    return WebNovelDetails(
      wenkuId: item["wenkuId"],
      titleJp: item["titleJp"] ?? "",
      titleZh: item["titleZh"] ?? "",
      authors: item["authors"]?.cast<Map<String, dynamic>>() ?? [],
      type: item["type"] ?? "",
      attentions: item["attentions"]?.cast<String>() ?? [],
      keywords: item["keywords"]?.cast<String>() ?? [],
      points: item["points"] ?? -1,
      totalCharacters: item["totalCharacters"] ?? -1,
      introductionJp: item["introductionJp"] ?? "",
      introductionZh: item["introductionZh"] ?? "",
      glossary: item["glossary"] ?? {},
      toc: item["toc"]?.cast<Map<String, dynamic>>() ?? [],
      visited: item["visited"] ?? -1,
      syncAt: item["syncAt"] ?? -1,
      favored: item["favored"],
      lastReadChapterId: item["lastReadChapterId"],
      jp: item["jp"] ?? -1,
      baidu: item["baidu"] ?? -1,
      youdao: item["youdao"] ?? -1,
      gpt: item["gpt"] ?? -1,
      sakura: item["sakura"] ?? -1,
    );
  }
}
