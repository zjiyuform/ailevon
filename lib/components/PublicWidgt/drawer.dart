import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ailevon/components/PublicWidgt/avatar.dart';
import 'package:ailevon/stores/theme_controller.dart';
import 'package:ailevon/stores/token_manager.dart';
import 'package:ailevon/stores/user_controller.dart';
import 'package:ailevon/viewmodels/user.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  // 主页初始化时Get.put(), 在此处Get.find()
  final UserController _userController = Get.find();
  final ThemeController _themeController = Get.find(); // 获取主题控制器

  // 返回退出登录组件的方法
  Widget _getLogout() {
    return GestureDetector(
      onTap: () {
        // 弹出确认框
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("提示"),
              content: Text("确认退出登录吗"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("取消", style: TextStyle(color: Colors.green)),
                ),
                TextButton(
                  onPressed: () async {
                    // 清除GetX, 清除token
                    await tokenManager.removeToken();
                    // Getx内存数据, 置空
                    _userController.updateUserInfo(UserInfo.fromJSON({}));
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: Text("确认", style: TextStyle(color: Colors.green)),
                ),
              ],
            );
          },
        );
      },
      child: Text("退出登录"),
    );
  }

  Obx _getUsername() {
    return Obx(() {
      // Obx中必须要有可监测的响应式数据
      return GestureDetector(
        onTap: () {
          if (_userController.user.value.username.isEmpty) {
            // 当没有user信息时可以去登录
            Navigator.pushNamed(context, "/login");
          }
        },
        child: Text(
          _userController.user.value.username.isNotEmpty
              ? "@${_userController.user.value.username}"
              : "点击登录",
          style: TextStyle(fontSize: 16),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Drawer(
        child: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(color: Colors.green, height: 20),
              //  抽屉头部放头像，和AppBar呼应
              UserAccountsDrawerHeader(
                accountName: _getUsername(),
                accountEmail: null,
                currentAccountPicture: PubAvatar(),
                decoration: BoxDecoration(color: Colors.green),
              ),
              // 抽屉其他菜单项...
              ListTile(
                leading: Icon(Icons.download),
                title: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, "/downloadmanager"),
                  child: Text("下载内容"),
                ),
              ),
              if (_userController.user.value.username.isNotEmpty)
                ListTile(leading: Icon(Icons.logout), title: _getLogout()),

              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: ListTile(
                      leading: Obx(
                        () => Icon(
                          _themeController.themeMode.value == ThemeMode.light
                              ? Icons.light_mode
                              : Icons.dark_mode,
                          color:
                              _themeController.themeMode.value ==
                                  ThemeMode.light
                              ? Colors.amber
                              : Colors.white70,
                        ),
                      ),
                      title: Text("主题模式"),
                      trailing: Obx(
                        () => Switch(
                          value:
                              _themeController.themeMode.value ==
                              ThemeMode.dark,
                          onChanged: (_) => _themeController.toggleTheme(),
                          activeThumbColor: Colors.green,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
