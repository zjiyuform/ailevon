// 声明一个 home主页 的wenku小说项类
class WenkuNovelItem {
  String id;
  String title;
  String titleZh;
  String cover;
  WenkuNovelItem({
    required this.id,
    required this.title,
    required this.titleZh,
    required this.cover,
  });
  // 拓展一个工厂函数 一般用factory来声明 一般用来创建实例对象
  factory WenkuNovelItem.fromJSON(Map<String, dynamic> item) {
    // 必须返回一个WebNovelItem对象
    return WenkuNovelItem(
      id: item["id"] ?? "",
      title: item["title"] ?? "",
      titleZh: item["titleZh"] ?? "",
      cover: item["cover"] ?? "",
    );
  }
}

// wenku小说
class WenkuPageNumber {
  List<WenkuNovelItem> items;
  String pageNumber;
  WenkuPageNumber({required this.items, required this.pageNumber});
  factory WenkuPageNumber.fromJSON(Map<String, dynamic> json) {
    return WenkuPageNumber(
      items: (json["items"] as List? ?? [])
          .map((item) => WenkuNovelItem.fromJSON(item as Map<String, dynamic>))
          .toList(),
      pageNumber: (json["pageNumber"] as String?) ?? "",
    );
  }
}
