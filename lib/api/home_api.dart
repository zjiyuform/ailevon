// 封装一个api 目的是返回业务侧要的数据结构
import 'package:ailevon/constants/constants.dart';
import 'package:ailevon/utils/dio_reqeust.dart';
// import 'package:ailevon/viewmodels/home.dart';
import 'package:ailevon/viewmodels/web.dart';
import 'package:ailevon/viewmodels/wenku.dart';

// 封装WEB小说请求API(home主页使用)
Future<List<WebNovelItem>> getHomeWebNovelListAPI() async {
  // 返回请求
  // 将获取的JSON列表转化为List数据结构, 调用List的map()方法, 将子项迭代映射为 WebNovelItem 类型
  return (await dioRequest.getItems(
            "/api/novel?page=0&pageSize=20&query=&provider=kakuyomu,syosetu,novelup,hameln,pixiv,alphapolis&type=0&level=1&translate=0&sort=1",
          )
          as List)
      .map((item) {
        return WebNovelItem.fromJSON(item as Map<String, dynamic>);
      })
      .toList(); // 调用toList()方法转化为 List<WebNovelItem>
}

// 封装wenku小说请求API
Future<List<WenkuNovelItem>> getWenkuNovelListAPI(
  Map<String, dynamic> params, // 存放请求参数
) async {
  // 返回请求
  // 将获取的JSON列表转化为List数据结构, 调用List的map()方法, 将子项迭代映射为 WebNovelItem 类型
  return (await dioRequest.getItems(HttpConstants.NOVEL_WENKU, params: params)
          as List)
      .map((item) {
        return WenkuNovelItem.fromJSON(item as Map<String, dynamic>);
      })
      .toList(); // 调用toList()方法转化为 List<WebNovelItem>
}
