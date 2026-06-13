// 声明一个 wenkudetails 主页 的wenkudetails小说项类
class WenkuNovelDetails {
  String title;
  String titleZh;
  String cover;
  List<String> authors;
  List<String> artists;
  List<String> keywords;
  String publisher;
  String imprint;
  int latestPublishAt;
  String level;
  String introduction;
  Map<String, dynamic> glossary;
  List<String> webIds;
  List<Map<String, dynamic>> volumes;
  int visited;
  List? volumeZh;
  List<Map<String, dynamic>> volumeJp;
  String? favored;
  WenkuNovelDetails({
    this.title = "",
    this.titleZh = "",
    this.cover = "",
    this.authors = const [],
    this.artists = const [],
    this.keywords = const [],
    this.publisher = "",
    this.imprint = "",
    this.latestPublishAt = -1,
    this.level = "",
    this.introduction = "",
    this.glossary = const {},
    this.webIds = const [],
    this.volumes = const [],
    this.visited = -1,
    this.volumeZh,
    this.volumeJp = const [],
    this.favored,
  });
  // 拓展一个工厂函数 一般用factory来声明 一般用来创建实例对象
  factory WenkuNovelDetails.fromJSON(Map<String, dynamic> item) {
    // 必须返回一个WebNovelItem对象
    return WenkuNovelDetails(
      title: item["title"] ?? "",
      titleZh: item["titleZh"] ?? "",
      cover: item["cover"] ?? "",
      authors: item["authors"]?.cast<String>() ?? [],
      artists: item["artists"]?.cast<String>() ?? [],
      keywords: item["keywords"]?.cast<String>() ?? [],
      publisher: item["publisher"] ?? "",
      imprint: item["imprint"] ?? "",
      latestPublishAt: item["latestPublishAt"] ?? -1,
      level: item["level"] ?? "",
      introduction: item["introduction"] ?? "",
      glossary: item["glossary"] ?? {},
      webIds: item["webIds"]?.cast<String>() ?? [],
      volumes: item["volumes"]?.cast<Map<String, dynamic>>() ?? [],
      visited: item["visited"] ?? -1,
      volumeZh: [],
      volumeJp: item["volumeJp"]?.cast<Map<String, dynamic>>() ?? [],
      favored: item["favored"],
    );
  }
}
