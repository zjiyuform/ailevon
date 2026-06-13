class NovelData {
  String titleJp;
  String titleZh;
  String? prevId;
  String? nextId;
  List<String> paragraphs;
  List<String>? baiduParagraphs;
  List<String>? youdaoParagraphs;
  List<String>? gptParagraphs;
  List<String>? sakuraParagraphs;

  NovelData({
    this.titleJp = "",
    this.titleZh = "",
    this.paragraphs = const [],
    this.prevId,
    this.nextId,
    this.baiduParagraphs,
    this.youdaoParagraphs,
    this.gptParagraphs,
    this.sakuraParagraphs,
  });

  factory NovelData.fromJson(Map<String, dynamic> item) {
    return NovelData(
      titleJp: item["titleJp"] ?? "",
      titleZh: item["titleZh"] ?? "",
      prevId: item["prevId"],
      nextId: item["nextId"],
      paragraphs: item["paragraphs"]?.cast<String>() ?? [],
      baiduParagraphs: item["baiduParagraphs"]?.cast<String>(),
      youdaoParagraphs: item["youdaoParagraphs"]?.cast<String>(),
      gptParagraphs: item["gptParagraphs"]?.cast<String>(),
      sakuraParagraphs: item["sakuraParagraphs"]?.cast<String>(),
    );
  }
}
