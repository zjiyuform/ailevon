// web_top.dart
import 'package:flutter/material.dart';
import 'package:ailevon/components/PublicWidgt/avatar.dart';

class StarTop extends StatefulWidget {
  // 接收由父组件传递的tap控制器
  final TabController? tabController; // 由父组件传入
  const StarTop({super.key, this.tabController});

  @override
  State<StarTop> createState() => _StarTopState();
}

class _StarTopState extends State<StarTop> {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      title: Text("我的收藏"),
      centerTitle: true,
      leading: Builder(
        // Builder 用来获取正确的 Scaffold 上下文，否则无法打开抽屉
        builder: (context) => IconButton(
          icon: PubAvatar(),
          // 点击头像打开抽屉，和原菜单按钮功能一致
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            if (widget.tabController?.index == 0) {
              Navigator.pushNamed(context, "/websearch");
            } else if (widget.tabController?.index == 1) {
              Navigator.pushNamed(context, "/wenkusearch");
            }
          },
          icon: const Icon(Icons.read_more),
        ),
        const SizedBox(width: 10),
      ],
      bottom: TabBar(
        controller: widget.tabController, // 使用传入的控制器
        labelColor: Colors.green, // 选中时字体颜色
        indicatorColor: Colors.green,
        overlayColor: WidgetStateProperty.resolveWith<Color?>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.pressed)) {
            return Theme.of(context).splashColor; // 改变按压时的背景颜色
          }
          return null;
        }), // 按压颜色
        tabs: const [
          Tab(text: "网络小说"),
          Tab(text: "文库小说"),
        ],
      ),
    );
  }
}
