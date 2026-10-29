import 'package:ailevon/constants/constants.dart';
import 'package:ailevon/utils/dio_request.dart';
import 'package:ailevon/viewmodels/comment.dart';
import 'package:dio/dio.dart';

Future<List<Comment>> getCommentApi({
  Map<String, dynamic>? params,
  String? address,
}) async {
  final List<dynamic> items =
      await dioRequest.getItems(
            "${HttpConstants.COMMENTS}/${address ?? ""}",
            params: params,
            options: Options(extra: {'baseUrl': GlobalConstants.FORUM_URL}),
          )
          as List;
  return items.map((item) => Comment.fromJson(item)).toList();
}
