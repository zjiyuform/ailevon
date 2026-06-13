import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ailevon/stores/user_controller.dart';

class PubAvatar extends StatefulWidget {
  const PubAvatar({super.key});

  @override
  State<PubAvatar> createState() => _PubAvatarState();
}

class _PubAvatarState extends State<PubAvatar> {
  final UserController _userController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => CircleAvatar(
        backgroundImage: _userController.user.value.username.isNotEmpty
            ? AssetImage("lib/assets/avatar/default_avatar.png")
            : null,
        backgroundColor: Colors.white, // 背景色在图片未加载或透明区域显示
      ),
    );
  }
}
