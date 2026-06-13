import 'package:flutter/material.dart';
import 'package:ailevon/api/star_api.dart';
import 'package:ailevon/components/Star/wenku_star_single.dart';
import 'package:ailevon/components/Wenku/wenku_area.dart';
import 'package:ailevon/utils/widget/loading_widght.dart';
import 'package:ailevon/viewmodels/wenku.dart';

class WenkuListTab extends StatefulWidget {
  final ScrollController? controller;
  const WenkuListTab({super.key, this.controller});

  @override
  State<WenkuListTab> createState() => _WenkuListTabState();
}

class _WenkuListTabState extends State<WenkuListTab>
    with AutomaticKeepAliveClientMixin {
  List<WenkuNovelItem> _wenkuNovelList = [];
  bool _isLoading = false;
  bool _isRequestFailure = false;

  final Map<String, dynamic> _totalParams = {
    "page": 0,
    "pageSize": 24,
    "sort": "update",
  };

  // 参数更新方法
  void updateParams(Map<String, dynamic> newParams) {
    setState(() {
      _totalParams.addAll(newParams);
    });
  }

  // 数据加载方法
  Future<void> _loadWenkuData() async {
    // if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      // print('最终请求参数: $_totalParams');
      final newData = await getFavoredWenkuListAPI(_totalParams);
      if (mounted) {
        setState(() {
          _wenkuNovelList = newData;
          _isLoading = false;
          _isRequestFailure = false;
          _page = 1;
          if (_wenkuNovelList.length < _totalParams["pageSize"]) {
            _hasMore = false;
          }
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
  List<WenkuNovelItem> _tempList = [];

  // 上拉加载更多（追加数据）
  Future<void> _getNewFavoredWenkuList() async {
    if (_isGetNewLoading || !_hasMore) return;
    if (mounted) setState(() => _isGetNewLoading = true);

    try {
      _tempList = await getFavoredWenkuListAPI({
        ..._totalParams,
        "page": _page,
      });

      if (mounted) {
        setState(() {
          // 追加数据
          _wenkuNovelList.addAll(_tempList);
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
      if (_isGetNewLoading || _wenkuNovelList.isEmpty) return;
      if (widget.controller!.position.pixels >=
          widget.controller!.position.maxScrollExtent) {
        _getNewFavoredWenkuList();
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
    // 重新执行所有获取数据函数, 将这些函数返回值从 void 改为 Future<void>
    _wenkuNovelList = await getFavoredWenkuListAPI(_totalParams);
    _hasMore = (_wenkuNovelList.length < _totalParams["pageSize"])
        ? false
        : true;
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
            await _loadWenkuData();
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
    _loadWenkuData();
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
        physics: AlwaysScrollableScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsetsGeometry.only(left: 30, right: 30, top: 10),
              child: WenkuStarSingle(
                filterMap: {
                  "排序": ["更新时间", "收藏时间"],
                },
                onFilterChanged: (filterParams) async {
                  updateParams(filterParams);
                  _hasMore = true;
                  await _loadWenkuData();
                },
              ),
            ),
          ),
          // 切换索引tag加载状态显示
          _isLoading
              ? LoadingWidght.showSliver()
              : _isRequestFailure
              ? _getRequestFailureWidget()
              : _wenkuNovelList.isEmpty
              ? SliverFillRemaining(child: Center(child: Text("暂无文库小说收藏")))
              : WenkuMainArea(wenkuNovelList: _wenkuNovelList),
          // 底部加载状态显示（和 wenku 一样）
          SliverToBoxAdapter(
            child: _isGetNewLoading
                ? LoadingWidght.showCommon()
                : !_hasMore && _wenkuNovelList.isNotEmpty
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
