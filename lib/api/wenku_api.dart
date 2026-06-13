// 封装wenku小说请求API
import 'package:ailevon/constants/constants.dart';
import 'package:ailevon/utils/dio_reqeust.dart';
import 'package:ailevon/viewmodels/wenku.dart';

// // 含参数的包含items的API(wenku页使用)
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

// 含参数的包含items和page的API(wenku页需要page时使用)
Future<WenkuPageNumber> getWenkuPageNumberParamsAPI(
  Map<String, dynamic> params, // 存放请求参数
) async {
  // 返回请求
  return WenkuPageNumber.fromJSON(
    await dioRequest.getPageNumber(HttpConstants.NOVEL_WENKU, params: params),
  );
}
