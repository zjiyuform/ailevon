import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart'
    as extended;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ailevon/components/PublicWidgt/Novel_comment/half2_comment.dart';
import 'package:ailevon/components/WebNovelDetails/web_detail_half1.dart';
import 'package:ailevon/components/WebNovelDetails/web_half2_introduction.dart';
import 'package:ailevon/constants/constants.dart';
import 'package:ailevon/stores/chapter_options_controller.dart';
import 'package:ailevon/stores/theme_controller.dart';
import 'package:ailevon/utils/dio_reqeust.dart';
import 'package:ailevon/utils/widget/loading_widght.dart';
import 'package:ailevon/utils/widget/toast_utils.dart';
import 'package:ailevon/viewmodels/webdetails.dart';

class WebNovelDetailsPage extends StatefulWidget {
  final String providerId;
  final String novelId;
  const WebNovelDetailsPage({
    super.key,
    required this.providerId,
    required this.novelId,
  });

  @override
  State<WebNovelDetailsPage> createState() => _WebNovelDetailsPageState();
}

class _WebNovelDetailsPageState extends State<WebNovelDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List _address = [];
  final ChapterOptionsController _chapterOptionsController =
      Get.find<ChapterOptionsController>();
  // 声明一个初始化的WebNovelDetails对象属性
  WebNovelDetails _webNovel = WebNovelDetails();
  bool _isRequestFailure = false;

  // 获取详细信息_getWebNovelDetails()方法
  Future<void> _getWebNovelDetails() async {
    try {
      _webNovel = WebNovelDetails.fromJSON(
        (await dioRequest.getNovelDetails(
          "${HttpConstants.NOVEL_WEB}/${_address.join("/")}",
        )),
      );
      _isLoading = false;
      _isRequestFailure = false;
      setState(() {});
    } catch (e) {
      if (mounted) {
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
              await _getWebNovelDetails();
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
    _address = [widget.providerId, widget.novelId];
    _getWebNovelDetails();
    _tabController = TabController(
      length: 2,
      vsync: this,
      animationDuration: Duration.zero,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _chapterOptionsController.reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("小说介绍"), centerTitle: true),
      // 在整个页面禁用默认 scrollbar，避免 PrimaryScrollController 冲突
      body: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: extended.ExtendedNestedScrollView(
          pinnedHeaderSliverHeightBuilder: () => 48,
          onlyOneScrollInBody: true,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              _isLoading
                  ? LoadingWidght.showSliver()
                  : _isRequestFailure
                  ? _getRequestFailureWidget()
                  : WebDetailHalf1(
                      address: _address,
                      webNovel: _webNovel,
                      refFunction: () async {
                        setState(() {
                          _isLoading = true;
                          _getWebNovelDetails();
                        });
                      },
                    ),
              SliverPersistentHeader(
                pinned: true,
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
                    tabs: const [
                      Tab(text: "简介"),
                      Tab(text: "评论"),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              WebHalf2Introduction(
                introductions: [
                  _webNovel.introductionJp,
                  _webNovel.introductionZh,
                ],
              ),
              Half2Comment(adress: ["web", widget.providerId, widget.novelId]),
            ],
          ),
        ),
      ),
    );
  }
}

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
