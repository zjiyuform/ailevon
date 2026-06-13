import 'package:flutter/material.dart';
import 'package:ailevon/api/web_api.dart';
import 'package:ailevon/components/WebNovel/web_area.dart';
import 'package:ailevon/components/WebNovel/web_filter.dart';
import 'package:ailevon/utils/widget/loading_widght.dart';
import 'package:ailevon/utils/widget/toast_utils.dart';
import 'package:ailevon/viewmodels/web.dart';

class WebSearchBody extends StatefulWidget {
  final ScrollController? controller;
  final String initialQuery; // 接收初始搜索词

  const WebSearchBody({super.key, this.controller, this.initialQuery = ""});

  @override
  State<WebSearchBody> createState() => _WebSearchBodyState();
}

class _WebSearchBodyState extends State<WebSearchBody> {
  List<WebNovelItem> _webNovelList = [];
  bool _isLoading = false;

  //  用于存储已存在的 novelId 集合
  final Set<String> _existNovelIds = {};

  final Map<String, dynamic> _totalParams = {
    "page": 0,
    "pageSize": 20,
    "query": "",
    "level": 1,
    "provider": "kakuyomu,syosetu,novelup,hameln,pixiv,alphapolis",
    "type": 0,
    "translate": 0,
    "sort": 0,
  };

  // 调用的参数更新方法
  void _updateParams(Map<String, dynamic> newParams) {
    setState(() {
      _totalParams.addAll(newParams);
    });
  }

  //  重置/筛选数据加载方法
  Future<void> _loadWebData() async {
    // if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final newData = await getWebNovelListAPI(_totalParams);
      if (mounted) {
        setState(() {
          _webNovelList = newData;

          // 清空并重新填充当前页的所有 novelId
          _existNovelIds.clear();
          // 使用 item.novelId 作为唯一标识
          _existNovelIds.addAll(newData.map((item) => item.novelId));

          // 重置分页状态
          _page = 1;
          if (_webNovelList.length < _totalParams["pageSize"]) _hasMore = false;
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
  List<WebNovelItem> _tempList = [];

  // 上拉加载更多（基于 novelId 去重）
  Future<void> _getNewWebNovelList() async {
    if (_isGetNewLoading || !_hasMore) return;
    if (mounted) setState(() => _isGetNewLoading = true);

    try {
      _tempList = await getWebNovelListAPI({..._totalParams, "page": _page});

      if (mounted) {
        setState(() {
          // 遍历新数据，基于 novelId 判断
          for (var item in _tempList) {
            // 检查当前 item 的 novelId 是否已存在
            if (!_existNovelIds.contains(item.novelId)) {
              _webNovelList.add(item); // 追加列表
              _existNovelIds.add(item.novelId); // 登记 novelId
            }
          }

          // print(_webNovelList.length);
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
      if (_isGetNewLoading || _webNovelList.isEmpty) return;
      if (widget.controller!.position.pixels >=
          widget.controller!.position.maxScrollExtent) {
        _getNewWebNovelList();
      }
    };
    widget.controller?.addListener(_scrollListener!);
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: widget.controller,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        WebFilter(
          initialQuery: widget.initialQuery,
          onFilterChanged: (filterParams) async {
            _updateParams(filterParams);
            _hasMore = true;
            await _loadWebData();
          },
        ),
        _isLoading
            ? LoadingWidght.showSliver()
            : WebMainArea(webNovelList: _webNovelList),
        SliverToBoxAdapter(
          child: _isGetNewLoading
              ? LoadingWidght.showCommon()
              : !_hasMore && _webNovelList.isNotEmpty
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
