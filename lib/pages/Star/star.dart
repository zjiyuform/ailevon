import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ailevon/components/Star/star_top.dart';
import 'package:ailevon/pages/Star/webnovel/web_list_tab.dart';
import 'package:ailevon/pages/Star/wenku/wenku_list_tab.dart';
import 'package:ailevon/stores/user_controller.dart';

class StarView extends StatefulWidget {
  final ScrollController? controller;
  const StarView({super.key, this.controller});

  @override
  State<StarView> createState() => StarViewState();
}

class StarViewState extends State<StarView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 主页初始化时Get.put(), 在此处Get.find()
  final UserController _userController = Get.find();

  late final ScrollController _webController;
  late final ScrollController _wenkuController;
  // 记录当前激活的控制器
  ScrollController? _currentController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _webController = ScrollController();
    _wenkuController = ScrollController();

    _currentController = _webController; // 默认第一个 Tab

    // 监听 Tab 切换，更新当前激活的控制器
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _currentController = _tabController.index == 0
              ? _webController
              : _wenkuController;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _webController.dispose();
    _wenkuController.dispose();
    super.dispose();
  }

  /// 提供给父组件调用的回到顶部方法
  void scrollToTop({
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.ease,
  }) {
    if (_currentController != null && _currentController!.hasClients) {
      _currentController!.animateTo(0, duration: duration, curve: curve);
    }
  }

  List<Widget> _getChilden() {
    if (_userController.user.value.username.isNotEmpty) {
      return [
        WebListTab(controller: _webController),
        WenkuListTab(controller: _wenkuController),
      ];
    } else {
      return [
        CustomScrollView(
          slivers: [
            SliverFillRemaining(child: Center(child: Text("未登录, 点击左上角登录"))),
          ],
        ),
        CustomScrollView(
          slivers: [
            SliverFillRemaining(child: Center(child: Text("未登录, 点击左上角登录"))),
          ],
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      // 保留主控制器绑定，用于 main_page.dart 的回到顶部
      // controller: widget.controller,
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverOverlapAbsorber(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: StarTop(tabController: _tabController),
          ),
        ];
      },
      body: Obx(
        () => TabBarView(
          controller: _tabController,
          children: _getChilden(), // 每次 username 变化都会重新调用
        ),
      ),
    );
  }
}
