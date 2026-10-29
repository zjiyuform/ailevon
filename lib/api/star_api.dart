import 'package:ailevon/constants/constants.dart';
import 'package:ailevon/utils/dio_request.dart';
import 'package:ailevon/viewmodels/wenku.dart';
import 'package:ailevon/viewmodels/web.dart';

Future<List<WebNovelItem>> getFavoredWebListAPI(
  Map<String, dynamic> params, // 存放请求参数
) async {
  // 返回请求
  return (await dioRequest.getItems(HttpConstants.FAVORED_WEB, params: params)
          as List)
      .map((item) {
        return WebNovelItem.fromJSON(item as Map<String, dynamic>);
      })
      .toList(); // 调用toList()方法转化为 List<WebNovelItem>
}

Future<List<WenkuNovelItem>> getFavoredWenkuListAPI(
  Map<String, dynamic> params, // 存放请求参数
) async {
  // 返回请求
  return (await dioRequest.getItems(HttpConstants.FAVORED_WENKU, params: params)
          as List)
      .map((item) {
        return WenkuNovelItem.fromJSON(item as Map<String, dynamic>);
      })
      .toList(); // 调用toList()方法转化为 List<WenkuNovelItem>
}
