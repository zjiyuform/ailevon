import 'package:flutter/material.dart';
import 'package:ailevon/api/home_api.dart';
import 'package:ailevon/components/Home/home_top.dart';
import 'package:ailevon/components/Home/home_img.dart';
import 'package:ailevon/components/Home/home_web.dart';
import 'package:ailevon/components/Home/home_wenku.dart';
import 'package:ailevon/utils/widget/loading_widght.dart';
import 'package:ailevon/utils/widget/toast_utils.dart';
import 'package:ailevon/viewmodels/wenku.dart';
import 'package:ailevon/viewmodels/web.dart';

/* 
在components/Home下放置homePage所需要的组件
 */
class HomeView extends StatefulWidget {
  // 接收父组件传递的 ScrollController, 用于实现点击底部tap时,触发滚动事件
  final ScrollController? controller;
  const HomeView({super.key, this.controller});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // 1.1 定义一个属性来接收, 存放轮播图项, 类型为 List<BannerItem>, 再父传子, 传递给HomeCarousel组件
  // List<BannerItem> _bannerList = [];
  // 2.1
  List<WebNovelItem> _webNovelList = [];
  // 3.1
  List<WenkuNovelItem> _wenkuNovelList = [];

  bool _isRefreshing = false;

  final int _pageSize = 24; // 请求数据长度

  // 1.2 定义一个方法来获取 List<BannerItem>, 获取轮播图数据
  // Future<void> _getBannerList() async {
  //   _bannerList = await getBannerListAPI();
  //   // setState(() {}); // 更新ui数据 // 刷新方法一同调用了setState, 所以此处可以注释
  // }

  // 2.2 获取web小说数据
  Future<void> _getWebNovelList() async {
    _webNovelList = await getHomeWebNovelListAPI();
    // setState(() {}); // 刷新方法一同调用了setState, 所以此处可以注释
  }

  // 3.2 获取wenku小说数据
  Future<void> _getWenkuNovelList() async {
    _wenkuNovelList = await getWenkuNovelListAPI({
      "page": 0,
      "pageSize": _pageSize,
      "query": "",
      "level": "0",
    });
    // if (mounted) setState(() {});
  }

  // 3.3 获取wenku小说 新数据
  int _page = 1; // 页码
  bool _isLoading = false; // 是否在请求
  bool _hasMore = true; // 是否有下一页
  List<WenkuNovelItem> _tempList = []; // 设置一个 tempList 用于存放获取的数据
  Future<void> _getNewWenkuNovelList() async {
    if (_isLoading || !_hasMore) return;

    if (mounted) setState(() => _isLoading = true);

    try {
      _tempList = await getWenkuNovelListAPI({
        "page": _page,
        "pageSize": _pageSize,
        "query": "",
        "level": "0",
      });

      if (mounted) {
        setState(() {
          _wenkuNovelList.addAll(_tempList);
          _isLoading = false;
        });
      }

      if (_tempList.length < _pageSize) {
        _hasMore = false;
      } else {
        _page++;
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      ToastUtils2.showToastBottom("获取失败(｡T ω T｡)");
    }
  }

  VoidCallback? _scrollListener; // 保存监听引用
  // 监听滚动到底部
  void _scrollBottomEvent() {
    // 先移除旧的监听
    if (_scrollListener != null && widget.controller != null) {
      widget.controller!.removeListener(_scrollListener!);
    }
    _scrollListener = () {
      if (_isLoading || _wenkuNovelList.isEmpty) return;
      if (widget.controller!.position.pixels >=
          widget.controller!.position.maxScrollExtent) {
        _getNewWenkuNovelList();
      }
    };
    widget.controller?.addListener(_scrollListener!);
  }

  // 上拉刷新 设置刷新方法
  Future<void> _onRefresh() async {
    if (_isRefreshing) return;
    _isRefreshing = true;

    // 获取文库数据的属性, 回归初始值
    _page = 1;
    _isLoading = false;
    _hasMore = true;
    _tempList = [];
    // _wenkuNovelList = [];
    // 重新执行所有获取数据方法, 将这些方法返回值从 void 改为 Future<void>
    // await _getBannerList();
    try {
      await _getWebNovelList();
      await _getWenkuNovelList(); // 使用 await 等待所有异步任务执行

      // 执行setState()方法, (因为此处等待所有请求完成后,调用setState,视图数据是最新的)
      setState(() {});

      // 刷新执行后显示文本
      if (mounted) {
        ToastUtils2.showToast("Ciallo～ (∠・ω< )⌒★"); // 顶部
      }
    } catch (e) {
      ToastUtils2.showToast("获取失败(｡T ω T｡)");
    } finally {
      _isRefreshing = false;
    }
  }

  // GlobalKey是一个方法可以创建一个key绑定到Widght部件上, 可以操作Wight部件
  final GlobalKey<RefreshIndicatorState> _key1 =
      GlobalKey<RefreshIndicatorState>();

  // 99. 获取自定义滚动容器的内容
  List<Widget> _getScrollChildren() {
    List<Widget> children = [
      HomeSearch(), // 搜索栏组件
    ];
    children.addAll([
      HomeTopimg(), // 顶部图片组件
      SliverToBoxAdapter(
        child: Container(
          height: 40,
          // color: Colors.amber,
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Stack(
            children: [
              // 居中文本
              const Center(
                child: Text(
                  "网络小说",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              // 右侧图标
              Positioned(
                right: 10,
                bottom: 8,
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, "/websearch"),
                  child: const Icon(Icons.read_more),
                ),
              ),
            ],
          ),
        ),
      ), //此处使用此设置间距加web小说标题
      HomeWeb(webNovelList: _webNovelList), // web小说组件
      SliverToBoxAdapter(
        child: Container(
          height: 40,
          // color: Colors.amber,
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Stack(
            children: [
              // 居中文本
              const Center(
                child: Text(
                  "文库小说",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              // 右侧图标
              Positioned(
                right: 10,
                bottom: 8,
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, "/wenkusearch"),
                  child: const Icon(Icons.read_more),
                ),
              ),
            ],
          ),
        ),
      ), //此处使用此设置间距加文库小说标题
      HomeWenku(wenkuNovelList: _wenkuNovelList), // 文库小说组件
      //  这里是显示加载圈和"没有更多"的逻辑
      SliverToBoxAdapter(
        child: _isLoading
            ? LoadingWidght.showCommon()
            : !_hasMore && _wenkuNovelList.isNotEmpty
            ? Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Center(child: Text("没有更多了")),
              )
            : SizedBox.shrink(), // SizedBox.shrink() '空返回' 写法, 自身宽高都压缩为 0
      ),
    ]);
    return children;
  }

  // 重新initState()方法, 在初始化阶段获取数据
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _key1.currentState?.show();
    });
    _scrollBottomEvent();
  }

  @override
  Widget build(BuildContext context) {
    // 使用 RefreshIndicator 包裹子组件，向下拉触发 onRefresh 方法
    return RefreshIndicator(
      // 绑定key
      key: _key1,
      color: Colors.green,
      onRefresh: _onRefresh,
      child: CustomScrollView(
        controller: widget.controller,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: _getScrollChildren(),
      ),
    );
  }
}
