import 'package:flutter/material.dart';
import 'package:ailevon/api/comment_api.dart';
import 'package:ailevon/utils/widget/loading_widght.dart';
import 'package:ailevon/utils/widget/toast_utils.dart';
import 'package:ailevon/components/PublicWidgt/Novel_comment/coment_item.dart';
import 'package:ailevon/viewmodels/comment.dart';

class Half2Comment extends StatefulWidget {
  final ScrollController? controller;
  final List<String>? adress;
  const Half2Comment({super.key, this.controller, this.adress});

  @override
  State<Half2Comment> createState() => _Half2CommentState();
}

class _Half2CommentState extends State<Half2Comment>
    with AutomaticKeepAliveClientMixin {
  final List<Comment> _commentList = [];
  bool _isLoading = false;
  bool _isRequestFailure = false;

  final int _pageSize = 20; // 请求数据长度

  Future<void> _getComment() async {
    setState(() => _isLoading = true);
    try {
      final comments = await getCommentApi(
        params: {"page": 1, "page_size": _pageSize},
        address: widget.adress!.join("-"),
      );
      setState(() {
        _commentList.addAll(comments);
        _isLoading = false;
        _isRequestFailure = false;
        if (_commentList.length < _pageSize) _hasMore = false;
      });
    } catch (e) {
      // print(e);
      setState(() {
        _isRequestFailure = true;
        _isLoading = false;
      });
    }
  }

  int _page = 2;
  bool _isGetNewLoading = false;
  bool _hasMore = true;
  List<Comment> _tempList = [];

  Future<void> _getNewCommentList() async {
    if (_isGetNewLoading || !_hasMore) return;
    if (mounted) setState(() => _isGetNewLoading = true);

    try {
      _tempList = await getCommentApi(
        params: {"page": _page, "page_size": _pageSize},
        address: widget.adress!.join("-"),
      );

      if (mounted) {
        setState(() {
          _commentList.addAll(_tempList);
          _isGetNewLoading = false;
        });

        if (_tempList.length < _pageSize) {
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

  SizedBox _getRequestFailureWidget() {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("评论获取失败"),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () async {
              setState(() {
                _isLoading = true;
              });
              await _getComment();
            },
            style: TextButton.styleFrom(backgroundColor: Colors.green),
            child: Text("重试获取", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  late VoidCallback _throttledGetNewComment;
  // 节流函数：立即执行第一次，然后冷却 [duration] 内不再执行
  void Function() throttle(VoidCallback action, Duration duration) {
    DateTime? lastCall;
    return () {
      final now = DateTime.now();
      if (lastCall == null || now.difference(lastCall!) > duration) {
        lastCall = now;
        action();
      }
    };
  }

  @override
  void initState() {
    super.initState();
    // 获取评论
    _getComment();
    // 加载节流函数
    _throttledGetNewComment = throttle(() {
      _getNewCommentList();
    }, const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _isLoading
        ? LoadingWidght.showCommon()
        : _isRequestFailure
        ? _getRequestFailureWidget()
        : _commentList.isNotEmpty
        ? NotificationListener<OverscrollNotification>(
            onNotification: (notification) {
              if (notification.overscroll > 1) {
                _throttledGetNewComment();
              }
              return false; // 不阻止冒泡
            },
            child: CustomScrollView(
              slivers: [
                SliverList.builder(
                  itemCount: _commentList.length,
                  itemBuilder: (context, index) {
                    final comment = _commentList[index];
                    return CommentItem(comment: comment);
                  },
                ),
                SliverToBoxAdapter(
                  child: _isGetNewLoading
                      ? LoadingWidght.showCommon()
                      : !_hasMore && _commentList.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: Center(child: Text("没有更多了")),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          )
        : CustomScrollView(
            slivers: [SliverFillRemaining(child: Center(child: Text("暂无评论")))],
          );
  }

  @override
  bool get wantKeepAlive => true;
}
