import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:ailevon/api/login.dart';
import 'package:ailevon/components/PublicWidgt/drawer.dart';
// import 'package:ailevon/pages/Bookshelf/bookshelf.dart';
import 'package:ailevon/pages/Home/home.dart';
import 'package:ailevon/pages/ReadHistory/read_history.dart';
import 'package:ailevon/pages/ReadHistory/store/record_controller.dart';
import 'package:ailevon/pages/Star/star.dart';
import 'package:ailevon/stores/chapter_options_controller.dart';
import 'package:ailevon/stores/read_position_controller.dart';
import 'package:ailevon/stores/read_settings_controller.dart';
import 'package:ailevon/stores/token_manager.dart';
import 'package:ailevon/stores/user_controller.dart';
import 'package:ailevon/stores/web_download_controller.dart';
import 'package:ailevon/viewmodels/user.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // 定义数据 根据数据进行渲染导航
  final List<Map<String, dynamic>> _tabList = [
    {"icon": Icons.home, "text": "首页"},
    {"icon": Icons.star, "text": "收藏"},
    {"icon": Icons.history, "text": "历史"},
    // {"icon": Icons.chrome_reader_mode, "text": "书架"},
    // {"icon": Icons.forum, "text": "论坛"},
  ];

  // 变量计入当前索引
  int _currentIndex = 0; // 初始为0

  // 返回List<BottomNavigationBarItem>的方法
  List<BottomNavigationBarItem> _getTabBarWidget() {
    return List.generate(_tabList.length, (index) {
      return BottomNavigationBarItem(
        icon: Icon(_tabList[index]["icon"], color: Colors.grey),
        label: _tabList[index]["text"],
        activeIcon: Icon(_tabList[index]["icon"], color: Colors.green),
      );
    });
  }

  // 使用 List.generate 为每个索引创建独立的 ScrollController：
  final List<ScrollController> _controllerList = List.generate(
    2,
    (index) => ScrollController(),
  );

  void _scrollListToTop(List<ScrollController> list, int index) {
    if (list[index].position.pixels < 10000) {
      list[index].animateTo(
        0,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    } else {
      list[index].jumpTo(0);
    }
  }

  // 在父组件中定义 GlobalKey
  final GlobalKey<StarViewState> _starViewKey = GlobalKey();

  //  返回对应tap的组件页面的方法
  List<Widget> _getChildren() {
    return [
      HomeView(controller: _controllerList[0]),
      StarView(key: _starViewKey),
      ReadHistoryView(controller: _controllerList[1]),
      // BookshelfView(),
      // ForumView(controller: _controllerList[1]),
    ];
  }

  // 初始化 全局数据共享控制器
  final UserController _userController = Get.put(UserController());
  // 在首页初始化用户(拥有token后)
  Future<void> _initUser() async {
    // 初始化储存的token
    await tokenManager.init();
    if (tokenManager.getToken().isNotEmpty) {
      // 如果存在token
      Map<String, dynamic> userProfile = JwtDecoder.decode(
        tokenManager.getToken(),
      );
      // print(userProfile);
      int currentTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      if (currentTimestamp < userProfile['exp']) {
        // token 未过期
        _userController.updateUserInfo(UserInfo.fromJSON(userProfile));
        // print("oldToken: ${tokenManager.getToken()}");
        _refreshUserToken();
      } else {
        // token 已过期
        _userController.updateUserInfo(UserInfo.fromJSON({}));
      }
    } else {
      // print("未找到token");
    }
  }

  // 刷新token方法
  Future<void> _refreshUserToken() async {
    // print("refresh-token: ${await tokenManager.getRefreshToken()}");
    final res = await refreshLoginIofoAPI();
    // print("newtoken: ${res.token}");
    // 进行token持久化
    tokenManager.setToken(res.token ?? ""); // 写入持久化
    // 刷新成功后 传入用户信息
    _userController.updateUserInfo(res);
  }

  @override
  void initState() {
    super.initState();
    // 初始化用户
    _initUser();
    // put获取章节选项控制器
    Get.put(ChapterOptionsController());
    // put获取历史记录选控制器
    Get.put(RecordController());
    // put获取下载设置控制器
    Get.put(WebDownloadController());
    // put 获取web章节目录正反序控制器
    Get.put(ReadSettingsController());
    // put 获取阅读章节滚动位置
    Get.put(ReadPositionController());
  }

  @override
  void dispose() {
    // 销毁所有 ScrollController
    for (var controller in _controllerList) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // safeArea组件避开安全区
      body: SafeArea(
        // IndexedStack堆叠组件，根据索引显示对应组件
        child: IndexedStack(index: _currentIndex, children: _getChildren()),
      ),
      bottomNavigationBar: BottomNavigationBar(
        showUnselectedLabels: true, // 使显示未被选中的字体

        selectedItemColor: Colors.green, // 设置被选中的字体颜色

        unselectedItemColor: Colors.grey, // 设置未被选中的字体颜色

        type: BottomNavigationBarType.fixed, // 被激活图标不触发动画效果
        onTap: (int index) {
          // 如果是当前索引, 那么触发回到顶部事件
          if (_currentIndex == index) {
            if (index == 0) {
              // _scrollToTop();
              _scrollListToTop(_controllerList, index);
            } else if (index == 1) {
              _starViewKey.currentState?.scrollToTop();
            } else if (index == 2) {
              _scrollListToTop(_controllerList, 1);
            }
          }
          // 时点击后的索引变成当前索引
          _currentIndex = index;
          setState(() {});
        },

        items: _getTabBarWidget(), //调用获取 List<BottomNavigationBarItem> 的方法
        currentIndex: _currentIndex,
      ),
      drawer: MyDrawer(),
    );
  }
}
