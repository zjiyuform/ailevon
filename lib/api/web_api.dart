// 封装一个api 目的是返回业务侧要的数据结构
import 'package:ailevon/constants/constants.dart';
import 'package:ailevon/utils/dio_reqeust.dart';
import 'package:ailevon/viewmodels/web.dart';

// 含参数的包含items的API(web页使用)
Future<List<WebNovelItem>> getWebNovelListAPI(
  Map<String, dynamic> params, // 存放请求参数
) async {
  // 返回请求
  return (await dioRequest.getItems(HttpConstants.NOVEL_WEB, params: params)
          as List)
      .map((item) {
        return WebNovelItem.fromJSON(item as Map<String, dynamic>);
      })
      .toList(); // 调用toList()方法转化为 List<WebNovelItem>
}

// 含参数的包含items和page的API(web页需要page时使用)
Future<WebPageJson> getWebPageJsonParamsAPI(
  Map<String, dynamic> params, // 存放请求参数
) async {
  // 返回请求
  return WebPageJson.fromJSON(
    await dioRequest.getPageNumber(HttpConstants.NOVEL_WEB, params: params),
  );
}
