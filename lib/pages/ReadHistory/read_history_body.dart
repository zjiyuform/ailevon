import 'package:ailevon/utils/widget/loading_widght.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ailevon/api/read_history.api.dart';
import 'package:ailevon/components/ReadHistory/web_read_history.dart';
import 'package:ailevon/pages/ReadHistory/store/record_controller.dart';
import 'package:ailevon/stores/user_controller.dart';
import 'package:ailevon/viewmodels/web.dart';

class ReadHistoryBody extends StatefulWidget {
  // 接收父组件传递的 ScrollController, 用于实现点击底部tap时,触发滚动事件
  final ScrollController? controller;
  final Function? subbmitRef;
  const ReadHistoryBody({super.key, this.controller, this.subbmitRef});

  @override
  State<ReadHistoryBody> createState() => _ReadHistoryBodyState();
}

class _ReadHistoryBodyState extends State<ReadHistoryBody> {
  List<WebNovelItem> _webNovelList = [];
  bool _isLoading = false;
  bool _isRequestFailure = false;

  final int _pageSize = 30;

  final UserController _userController = Get.find();

  final RecordController _recordController = Get.find<RecordController>();

  //  获取数据方法
  Future<void> _loadWebReadHistoryData() async {
    setState(() => _isLoading = true);
    try {
      final newData = await getWebNovelReadHistoryListAPI({
        "page": 0,
        "pageSize": _pageSize,
      });
      if (mounted) {
        setState(() {
          _webNovelList = newData;
          _isLoading = false;
          _isRequestFailure = false;
          if (_webNovelList.length < _pageSize) _hasMore = false;
        });
      }
      // print(_webNovelList);
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
  Future<void> _getNewWebNovelReadHistory() async {
    if (_isGetNewLoading || !_hasMore) return;
    if (mounted) setState(() => _isGetNewLoading = true);

    try {
      _tempList = await getWebNovelReadHistoryListAPI({
        "page": _page,
        "pageSize": _pageSize,
      });

      if (mounted) {
        setState(() {
          // 追加数据
          _webNovelList.addAll(_tempList);
          _isGetNewLoading = false;
        });

        // 判断是否还有更多
        if (_tempList.length < _pageSize) {
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
      if (_isGetNewLoading) return;
      if (widget.controller!.position.pixels >=
          widget.controller!.position.maxScrollExtent) {
        _getNewWebNovelReadHistory();
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
    // 重新执行所有获取数方法, 将这些方法返回值从 void 改为 Future<void>
    _webNovelList = await getWebNovelReadHistoryListAPI({
      "page": 0,
      "pageSize": _pageSize,
    });
    _hasMore = _webNovelList.length < _pageSize ? false : true;
    await _recordController.getIsPaused();
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
            await _loadWebReadHistoryData();
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
    if (_userController.user.value.username.isNotEmpty) {
      _loadWebReadHistoryData();
      _scrollBottomEvent();
      // 将刷新方法传递给父组件
      widget.subbmitRef!(_onRefresh);
      // 异步微任务调用, 获取是否关闭记录的结果
      Future.microtask(() async {
        await _recordController.getIsPaused();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: Colors.green,
      onRefresh: _onRefresh,
      edgeOffset: 24,
      displacement: 40,
      child: CustomScrollView(
        controller: widget.controller,
        physics: AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          ),
          SliverToBoxAdapter(child: const SizedBox(height: 10)),
          if (_recordController.isPaused.value)
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Text("注意：历史功能已暂停", style: TextStyle(color: Colors.amber)),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          _isLoading
              ? LoadingWidght.showSliver()
              : _isRequestFailure
              ? _getRequestFailureWidget()
              : _webNovelList.isEmpty
              ? SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: Text('暂无阅读历史')),
                )
              : WebReadHistory(
                  webNovelList: _webNovelList,
                  refFunction: () async {
                    // _isLoading = true;
                    await _onRefresh();
                  },
                ),

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
}
