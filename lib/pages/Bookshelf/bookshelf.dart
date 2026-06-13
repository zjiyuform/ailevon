// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:ailevon/api/login.dart';
import 'package:ailevon/components/PublicWidgt/avatar.dart';
import 'package:ailevon/pages/WebRead/novel_reader_page.dart';
import 'package:ailevon/pages/DownloadManager/download_manager_page.dart';
import 'package:ailevon/stores/token_manager.dart';

class BookshelfView extends StatefulWidget {
  // 接收父组件传递的 ScrollController, 用于实现点击底部tap时,触发滚动事件
  final ScrollController? controller;
  const BookshelfView({super.key, this.controller});

  @override
  State<BookshelfView> createState() => _BookshelfViewState();
}

class _BookshelfViewState extends State<BookshelfView> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: widget.controller,
      slivers: [
        SliverAppBar(
          pinned: true, // 关键：滚动时保持吸顶
          title: Text("我的书架"),
          centerTitle: true,
          leading: Builder(
            // Builder 用来获取正确的 Scaffold 上下文，否则无法打开抽屉
            builder: (context) => IconButton(
              icon: PubAvatar(),
              // 点击头像打开抽屉，和原菜单按钮功能一致
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Center(
            child: TextButton(
              onPressed: () => Navigator.pushNamed(
                context,
                "/webnoveldetails?provider=${Uri.encodeComponent("syosetu")}&novelId=${Uri.encodeComponent("n4744ia")}&total=${Uri.encodeComponent("")}",
              ),
              child: Text("web测试页面"),
            ),
          ),
        ),
        SliverToBoxAdapter(child: const SizedBox(height: 10)),
        SliverToBoxAdapter(
          child: Center(
            child: TextButton(
              onPressed: () => Navigator.pushNamed(
                context,
                "/wenkunoveldetails?id=${Uri.encodeComponent("6450c4b984972153850fa920")}",
              ),
              child: Text("wenku测试页面"),
            ),
          ),
        ),

        SliverToBoxAdapter(child: const SizedBox(height: 10)),
        SliverToBoxAdapter(
          child: Center(
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NovelReaderPage(
                      address: ["kakuyomu", "822139845979814862"],
                      chapterId: "822139846229341119",
                      toc: [],
                    ),
                  ),
                );
              },
              child: Text("webread测试页面"),
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Center(
            child: TextButton(
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DownloadManagerPage(),
                  ),
                );
              },
              child: Text("download"),
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Center(
            child: TextButton(
              onPressed: () async {
                print("refresh-token: ${await tokenManager.getRefreshToken()}");
                final res = await refreshLoginIofoAPI();
                print("newtoken: ${res.token}");
              },
              child: Text("refretoken测试"),
            ),
          ),
        ),
      ],
    );
  }
}
