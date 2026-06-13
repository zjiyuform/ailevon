import 'package:get/get.dart';
import 'package:ailevon/viewmodels/user.dart';

// 需要共享的对象 要有一些共享的属性 属性需要响应式更新
class UserController extends GetxController {
  final user = UserInfo.fromJSON({}).obs; // .bos 使 user对象被监听
  // 如果想要取值, 需要 user.value
  // 设计更新user的方法
  void updateUserInfo(UserInfo newUser) {
    newUser.token = "";
    user.value = newUser;
  }
}
