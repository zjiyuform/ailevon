import 'package:ailevon/constants/constants.dart';
import 'package:ailevon/utils/dio_reqeust.dart';
import 'package:ailevon/viewmodels/comment.dart';

Future<List<Comment>> getCommentApi({Map<String, dynamic>? params}) async {
  final List<dynamic> items =
      await dioRequest.getItems(HttpConstants.COMMENTS, params: params) as List;
  return items.map((item) => Comment.fromJson(item)).toList();
}
