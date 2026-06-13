// 声明一个 home主页 的轮播图项类
class BannerItem {
  String id;
  String imgUrl;
  String title;
  String titleZh;
  BannerItem({
    required this.id,
    required this.imgUrl,
    required this.title,
    required this.titleZh,
  });
  // 拓展一个工厂函数 一般用factory来声明 一般用来创建实例对象
  factory BannerItem.fromJSON(Map<String, dynamic> item) {
    // 必须返回一个BannerItem对象
    return BannerItem(
      id: item["id"] ?? "",
      imgUrl: item["cover"] ?? "",
      title: item["title"] ?? "",
      titleZh: item["titleZh"] ?? "",
    );
  }
}

// Map<String, dynamic>
// 每个轮播图的具体类型 (item 为 items 的一项)
// flutter必须强制转化 没有隐式转化
