import 'package:flutter/material.dart';
import 'package:ailevon/api/wenku_api.dart';
import 'package:ailevon/components/Wenku/wenku_area.dart';
import 'package:ailevon/components/Wenku/wenku_filter.dart';
import 'package:ailevon/utils/widget/loading_widght.dart';
import 'package:ailevon/utils/widget/toast_utils.dart';
import 'package:ailevon/viewmodels/wenku.dart';

class WenkuSearchBody extends StatefulWidget {
  final ScrollController? controller;
  final String initialQuery; // 接收初始值
  const WenkuSearchBody({super.key, this.controller, this.initialQuery = ""});

  @override
  State<WenkuSearchBody> createState() => _WenkuSearchBodyState();
}

class _WenkuSearchBodyState extends State<WenkuSearchBody> {
  List<WenkuNovelItem> _wenkuNovelList = [];
  bool _isLoading = false;

  final Map<String, dynamic> _totalParams = {
    "page": 0,
    "pageSize": 24,
    "query": "",
    "level": 0,
  };

  // 供父组件调用的参数更新方法
  void updateParams(Map<String, dynamic> newParams) {
    setState(() {
      _totalParams.addAll(newParams);
    });
  }

  // 供父组件调用的数据加载方法
  Future<void> loadWebData() async {
    // if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      // print('最终请求参数: $_totalParams');
      final newData = await getWenkuNovelListAPI(_totalParams);
      if (mounted) {
        setState(() {
          _wenkuNovelList = newData;
          _page = 1;
          if (_wenkuNovelList.length < _totalParams["pageSize"]) {
            _hasMore = false;
          }
        });
      }
    } catch (e) {
      ToastUtils2.showToast("获取失败(｡T ω T｡)");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollBottomEvent(); //获取新数据
  }

  int _page = 1;
  bool _isGetNewLoading = false;
  bool _hasMore = true;
  List<WenkuNovelItem> _tempList = [];

  // 上拉加载更多（追加数据）
  Future<void> _getNewWenkuNovelList() async {
    if (_isGetNewLoading || !_hasMore) return;
    if (mounted) setState(() => _isGetNewLoading = true);

    try {
      _tempList = await getWenkuNovelListAPI({..._totalParams, "page": _page});

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
      ToastUtils2.showToastBottom("获取失败(｡T ω T｡)");
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
        _getNewWenkuNovelList();
      }
    };
    widget.controller?.addListener(_scrollListener!);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      // 绑定上级组件的controller
      controller: widget.controller,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        WenkuFilter(
          initialQuery: widget.initialQuery,
          onFilterChanged: (filterParams) async {
            updateParams(filterParams);
            _hasMore = true;
            await loadWebData();
          },
        ),
        // 切换索引tag加载状态显示
        _isLoading
            ? LoadingWidght.showSliver()
            : WenkuMainArea(wenkuNovelList: _wenkuNovelList),
        // 底部加载状态显示（和 wenku 一样）
        SliverToBoxAdapter(
          child: _isGetNewLoading
              ? LoadingWidght.showCommon()
              : !_hasMore && _wenkuNovelList.isNotEmpty
              ? Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Center(child: Text("没有更多了")),
                )
              : SizedBox.shrink(),
        ),
      ],
    );
  }
}
