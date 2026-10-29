import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart'
    as extended;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ailevon/components/PublicWidgt/Novel_comment/half2_comment.dart';
import 'package:ailevon/components/WenkuNovelDetails/wenku_half2_contents.dart';
import 'package:ailevon/components/WenkuNovelDetails/wenku_half2_introduction.dart';
import 'package:ailevon/constants/constants.dart';
import 'package:ailevon/components/WenkuNovelDetails/wenku_detail_half1.dart';
import 'package:ailevon/stores/theme_controller.dart';
import 'package:ailevon/utils/dio_request.dart';
import 'package:ailevon/utils/widget/loading_widght.dart';
import 'package:ailevon/utils/widget/toast_utils.dart';
import 'package:ailevon/viewmodels/wenkudetails.dart';

class WenkuDetailsPage extends StatefulWidget {
  final String id;
  const WenkuDetailsPage({super.key, required this.id});

  @override
  State<WenkuDetailsPage> createState() => _WenkuDetailsPageState();
}

// 1. 混入 SingleTickerProviderStateMixin 用于 Tab 动画
class _WenkuDetailsPageState extends State<WenkuDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  // 声明一个初始化的WenkuNovelDetails对象属性
  WenkuNovelDetails _wenkuNovel = WenkuNovelDetails();

  bool _isRequestFailure = false;

  // 获取详细信息_getWenkuNovelDetails()方法
  Future<void> _getWenkuNovelDetails() async {
    try {
      _wenkuNovel = WenkuNovelDetails.fromJSON(
        (await dioRequest.getNovelDetails(
          "${HttpConstants.NOVEL_WENKU}/${widget.id}",
        )),
      );
      _isLoading = false;
      _isRequestFailure = false;
      // print(_wenkuNovel);
      setState(() {});
    } catch (e) {
      if (mounted) {
        // print(e);
        ToastUtils2.showToast("获取失败(｡T ω T｡), 请重试");
        _isLoading = false;
        _isRequestFailure = true;
        setState(() {});
      }
    }
  }

  SliverToBoxAdapter _getRequestFailureWidget() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsetsGeometry.symmetric(vertical: 20),
        child: Center(
          child: TextButton(
            onPressed: () async {
              setState(() {
                _isLoading = true;
              });
              await _getWenkuNovelDetails();
            },
            style: TextButton.styleFrom(backgroundColor: Colors.green),
            child: Text("点击重试", style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _getWenkuNovelDetails();
    // 2. 初始化 TabController（length 是 Tab 数量）
    _tabController = TabController(
      length: 3,
      vsync: this,
      animationDuration: Duration.zero,
    );
  }

  @override
  void dispose() {
    // 3. 销毁 Controller 防止内存泄漏
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("小说介绍"), centerTitle: true),
      body: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: extended.ExtendedNestedScrollView(
          pinnedHeaderSliverHeightBuilder: () => 48,
          onlyOneScrollInBody: true,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              // --- 上半部分---
              _isLoading
                  ? LoadingWidght.showSliver()
                  : _isRequestFailure
                  ? _getRequestFailureWidget()
                  : WenkuDetailHalf1(
                      wenkuNovel: _wenkuNovel,
                      id: widget.id,
                      refFunction: () async {
                        setState(() {
                          _isLoading = true;
                          _getWenkuNovelDetails();
                        });
                      },
                    ),

              SliverPersistentHeader(
                pinned: true, // 让 Tab 栏固定在顶部
                delegate: _SliverTabBarDelegate(
                  TabBar(
                    controller: _tabController,
                    labelColor: Colors.green,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.green,
                    overlayColor: WidgetStateProperty.resolveWith<Color?>((
                      Set<WidgetState> states,
                    ) {
                      if (states.contains(WidgetState.pressed)) {
                        return Theme.of(context).splashColor; // 改变按压时的背景颜色
                      }
                      return null;
                    }), // 按压颜色
                    tabs: [
                      Tab(text: "简介"),
                      Tab(text: "目录"),
                      Tab(text: "评论"),
                    ],
                  ),
                ),
              ),
            ];
          },
          // --- 下半部分：Tab 切换的内容 ---
          body: TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              WenkuHalf2Introduction(introduction: _wenkuNovel.introduction),

              WenkuHalf2Contents(
                id: widget.id,
                volumeJp: _wenkuNovel.volumeJp,
                // title: _wenkuNovel.title,
              ),

              Half2Comment(adress: ["wenku", widget.id]),
            ],
          ),
        ),
      ),
    );
  }
}

// --- 让 TabBar 能嵌入 Sliver 并吸顶 ---
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  final ThemeController _themeController = Get.find();

  _SliverTabBarDelegate(this._tabBar);

  @override
  double get minExtent => 48;
  @override
  double get maxExtent => 48;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: _themeController.themeMode.value == ThemeMode.light
          ? Colors.white
          : Color(0xFF141218),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => false;
}
