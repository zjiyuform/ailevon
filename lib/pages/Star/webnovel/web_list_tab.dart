import 'package:flutter/material.dart';
import 'package:ailevon/api/star_api.dart';
import 'package:ailevon/components/Star/web_star_fliter.dart';
import 'package:ailevon/components/WebNovel/web_area.dart';
import 'package:ailevon/utils/widget/loading_widght.dart';
import 'package:ailevon/viewmodels/web.dart';

class WebListTab extends StatefulWidget {
  final ScrollController? controller;
  const WebListTab({super.key, this.controller});

  @override
  State<WebListTab> createState() => _WebListTabState();
}

class _WebListTabState extends State<WebListTab>
    with AutomaticKeepAliveClientMixin {
  // WebPageJson _webPageJson = WebPageJson(items: [], pageNumber: 0);
  List<WebNovelItem> _webNovelList = [];
  bool _isLoading = false;
  bool _isRequestFailure = false;

  final Map<String, dynamic> _totalParams = {
    "page": 0,
    "pageSize": 20,
    "query": "",
    "level": 1,
    "provider": "kakuyomu,syosetu,novelup,hameln,pixiv,alphapolis",
    "type": 0,
    "translate": 0,
    "sort": "update",
  };

  // 参数更新方法
  void updateParams(Map<String, dynamic> newParams) {
    setState(() {
      _totalParams.addAll(newParams);
    });
  }

  // 数据加载方法
  Future<void> _loadWebData() async {
    setState(() => _isLoading = true);

    try {
      // print('最终请求参数: $_totalParams');
      final newData = await getFavoredWebListAPI(_totalParams);
      if (mounted) {
        setState(() {
          _webNovelList = newData;
          _isLoading = false;
          _isRequestFailure = false;
          _page = 1;
          if (_webNovelList.length < _totalParams["pageSize"]) _hasMore = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isRequestFailure = true;
      });
    }
  }

  int _page = 1;
  bool _isGetNewLoading = false;
  bool _hasMore = true;
  List<WebNovelItem> _tempList = [];

  // 上拉加载更多（追加数据）
  Future<void> _getNewFavoredWebList() async {
    if (_isGetNewLoading || !_hasMore) return;
    if (mounted) setState(() => _isGetNewLoading = true);

    try {
      _tempList = await getFavoredWebListAPI({..._totalParams, "page": _page});

      if (mounted) {
        setState(() {
          // 追加数据
          _webNovelList.addAll(_tempList);
          _isGetNewLoading = false;
        });

        // 判断是否还有更多
        if (_tempList.length < _totalParams["pageSize"]) {
          _hasMore = false;
        } else {
          _page++;
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isGetNewLoading = false);
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
      if (_isGetNewLoading || _webNovelList.isEmpty) return;
      if (widget.controller!.position.pixels >=
          widget.controller!.position.maxScrollExtent) {
        _getNewFavoredWebList();
      }
    };
    widget.controller?.addListener(_scrollListener!);
  }

  // 上拉刷新 设置刷新方法
  Future<void> _onRefresh() async {
    // 获取文库数据的属性, 回归初始值
    _page = 1;
    _isLoading = false;
    _tempList = [];
    // 重新执行所有获取数据方法, 将这些方法返回值从 void 改为 Future<void>
    _webNovelList = await getFavoredWebListAPI(_totalParams);
    _hasMore = (_webNovelList.length < _totalParams["pageSize"]) ? false : true;
    setState(() {});
  }

  SliverFillRemaining _getRequestFailureWidget() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: TextButton(
          onPressed: () async {
            setState(() {
              _isLoading = true;
            });
            await _loadWebData();
          },
          style: TextButton.styleFrom(backgroundColor: Colors.green),
          child: Text("点击重试", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadWebData(); // 初始化时加载一次数据;
    _scrollBottomEvent(); //获取新数据
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return RefreshIndicator(
      color: Colors.green,
      onRefresh: _onRefresh,
      edgeOffset: 24,
      displacement: 80,
      child: CustomScrollView(
        // 绑定上级组件的controller
        controller: widget.controller,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          ),
          WebStarFliter(
            onFilterChanged: (filterParams) async {
              updateParams(filterParams);
              _hasMore = true;
              await _loadWebData();
            },
          ),
          // 切换索引tag加载状态显示
          _isLoading
              ? LoadingWidght.showSliver()
              : _isRequestFailure
              ? _getRequestFailureWidget()
              : _webNovelList.isEmpty
              ? SliverFillRemaining(child: Center(child: Text("暂无网络小说收藏")))
              : WebMainArea(webNovelList: _webNovelList),
          // 底部加载状态显示
          SliverToBoxAdapter(
            child: _isGetNewLoading
                ? Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                      ),
                    ),
                  )
                : !_hasMore && _webNovelList.isNotEmpty
                ? Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Center(child: Text("没有更多了( ´ ▽ ` )")),
                  )
                : SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
