import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ailevon/components/ReadWeb/bottom_option_bar.dart';
import 'package:ailevon/components/ReadWeb/novel_text.dart';
import 'package:ailevon/constants/constants.dart';
import 'package:ailevon/stores/chapter_options_controller.dart';
import 'package:ailevon/stores/read_position_controller.dart';
import 'package:ailevon/stores/read_settings_controller.dart';
import 'package:ailevon/stores/user_controller.dart';
import 'package:ailevon/utils/dio_reqeust.dart';
import 'package:ailevon/utils/widget/loading_widght.dart';
import 'package:ailevon/utils/widget/toast_utils.dart';
import 'package:ailevon/viewmodels/webread.dart';

class NovelReaderPage extends StatefulWidget {
  final List address;
  final String chapterId;
  final List<Map<String, dynamic>>? toc;
  const NovelReaderPage({
    super.key,
    required this.address,
    required this.chapterId,
    this.toc,
  });

  @override
  State<NovelReaderPage> createState() => _NovelReaderPageState();
}

class _NovelReaderPageState extends State<NovelReaderPage>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  NovelData _novelData = NovelData();
  NovelData? _preNovelData; // 预加载数据
  // 滚动控制器
  ScrollController _scrollController = ScrollController();
  final ReadSettingsController settings = Get.find<ReadSettingsController>();
  final UserController _userController = Get.find();
  final ReadPositionController _readPositionController = Get.find();
  final ChapterOptionsController _chapterOptionsController =
      Get.find<ChapterOptionsController>();
  // UI 控制
  bool _controlsVisible = false;
  Timer? _hideTimer;
  // 防抖与滑动状态
  bool _canSwipe = true; // 防抖锁
  bool _isDragging = false;
  double _dragTotalDelta = 0; // 累计滑动距离
  bool _isChapterLoading = false;
  // Getter（计算属性），只读, 不存储值
  double get _threshold => 60.0;

  int _currentChapterGlobalIndex = 0;

  double _scrollPosition = 0; // 滚动位置

  String _currentChapterId = ""; // 子组件传递当前章节

  void _subbmitcurrentChapterId(String currentChapterId) {
    _currentChapterId = currentChapterId;
    _scrollPosition = 0;
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _scrollController = ScrollController(initialScrollOffset: _scrollPosition);
    _scrollController.addListener(_onScroll);
  }

  int _getGlobalIndexFromToc(String chapterId) {
    if (widget.toc == null) return 0;
    int idx = 0;
    for (var item in widget.toc!) {
      if (item['chapterId'] != null) {
        if (item['chapterId'].toString() == chapterId) return idx;
        idx++;
      }
    }
    return 0;
  }

  Future<void> _getPreNextData({required String chapterId}) async {
    if (chapterId.isEmpty) return;
    try {
      final url =
          "${HttpConstants.NOVEL_WEB}/${widget.address.join("/")}/chapter/$chapterId";
      final json = await dioRequest.getNovelDetails(url);
      final novelData = NovelData.fromJson(json);
      _preNovelData = novelData;
    } catch (e) {
      _preNovelData = null;
    }
  }

  Future<void> _getChapterData({
    required String chapterId,
    bool isUpdateCI = true,
    bool isNxet = false,
  }) async {
    setState(() {
      _isLoading = true;
    });
    try {
      NovelData novelData;

      if (_preNovelData != null && isNxet) {
        novelData = _preNovelData!;
      } else {
        final url =
            "${HttpConstants.NOVEL_WEB}/${widget.address.join("/")}/chapter/$chapterId";
        final json = await dioRequest.getNovelDetails(url);
        novelData = NovelData.fromJson(json);
      }

      setState(() {
        // 更新记录的章节
        if (isUpdateCI) {
          _subbmitcurrentChapterId(chapterId);
        }
        _novelData = novelData;
        _preNovelData = null;
        _isLoading = false;
        _currentChapterGlobalIndex = _getGlobalIndexFromToc(chapterId);
      });

      try {
        if (_userController.user.value.username.isNotEmpty) {
          await dioRequest.dioPut(
            "${HttpConstants.READHISTORY}/${widget.address.join("/")}",
            data: chapterId,
          );
        }
        // print(widget.chapterId);
      } catch (e) {
        // print(e);
      }
    } catch (e) {
      if (mounted) {
        ToastUtils2.showToast("获取失败(｡T ω T｡), 请重试");
        setState(() => _isLoading = false);
      }
    }
  }

  // 显示控制栏，并启动自动隐藏计时
  void _showControls() {
    setState(() => _controlsVisible = true);
    // 展示恢复状态栏和导航栏
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values,
    );
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      // 隐藏状态栏和导航栏（完全沉浸模式）
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.immersiveSticky,
        overlays: [],
      );
      if (mounted) setState(() => _controlsVisible = false);
    });
  }

  // 隐藏控制栏
  void _hideControls() {
    _hideTimer?.cancel();
    // 隐藏状态栏和导航栏（完全沉浸模式）
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [],
    );
    if (mounted) setState(() => _controlsVisible = false);
  }

  //
  void _handleHorizontalDragStart(DragStartDetails details) {
    if (!_canSwipe) return;
    _isDragging = true;
    _dragTotalDelta = 0;
    // 滑动时取消控制栏自动隐藏
    _hideTimer?.cancel();
  }

  void _handleHorizontalDragUpdate(DragUpdateDetails details) {
    if (!_isDragging || !_canSwipe) return;
    _dragTotalDelta += details.delta.dx;

    // 实时检测：累计滑动距离超过阈值立即触发翻页
    if (_dragTotalDelta.abs() >= _threshold) {
      final direction = _dragTotalDelta > 0 ? 'prev' : 'next';
      _triggerChangeChapter(direction);
    }
  }

  void _handleHorizontalDragEnd(DragEndDetails details) {
    _isDragging = false;
    _dragTotalDelta = 0;
    // 恢复控制栏自动隐藏
    if (_controlsVisible) {
      _hideTimer?.cancel();
      _hideTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) setState(() => _controlsVisible = false);
      });
    }
  }

  Future<void> _triggerChangeChapter(String direction) async {
    if (!_canSwipe) return;
    setState(() => _canSwipe = false);
    _isDragging = false; // 立即停止本次手势，避免继续累加再次触发
    await _changeChapter(direction);
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _canSwipe = true);
    });
  }

  // 实际的章节切换
  Future<void> _changeChapter(String direction) async {
    if (_isChapterLoading) return;
    setState(() => _isChapterLoading = true);
    try {
      if (direction == 'next') {
        // 加载下一章
        if (_novelData.nextId != null) {
          // 调用加载组件方法
          await _getChapterData(chapterId: _novelData.nextId!, isNxet: true);
          await _getPreNextData(chapterId: _novelData.nextId ?? "");
          // print(_scrollController.position.pixels);
        } else {
          ToastUtils2.showToast("暂无下一章");
        }
        // print('切换到下一章');
      }
      if (direction == 'prev') {
        // 加载上一章
        if (_novelData.prevId != null) {
          await _getChapterData(chapterId: _novelData.prevId!);
        } else {
          if (mounted) {
            ToastUtils2.showToast("已是第一章");
          }
        }
        // print('切换到上一章');
      }
    } catch (e) {
      if (mounted) {
        ToastUtils2.showToast("切换失败");
      }
    } finally {
      if (mounted) setState(() => _isChapterLoading = false);
    }
  }

  // 点击底部栏使取消自动隐藏
  void _cancelAutoHide() {
    // 取消旧计时器
    _hideTimer?.cancel();
    // 重新开始 3 秒计时
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _controlsVisible = false);
    });
  }

  Color _getBackgroundColor() {
    switch (settings.bgColorOption.value) {
      case BackgroundColorOption.lightYellow:
        return const Color(0xFFFFF9E6);
      case BackgroundColorOption.lightGray:
        return const Color(0xFFF5F5F5);
      case BackgroundColorOption.lightPurple:
        return Color(0xFFF8F0FF);
      case BackgroundColorOption.darkGray:
        return const Color(0xFF2C2C2C);
    }
  }

  Timer? _saveTimer; // 用于防抖，避免高频保存
  /// 滚动时的回调
  void _onScroll() {
    // 确保控制器还有效且已附加到滚动视图
    if (!_scrollController.hasClients) return;

    // 防抖：停止滚动后 500ms 再保存，也可以实时保存（自行权衡）
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 500), () {
      if (_scrollController.hasClients) {
        final position = _scrollController.position.pixels;
        _saveCurrentPosition(position);
      }
    });
  }

  /// 保存当前章节和滚动位置
  void _saveCurrentPosition(double scrollOffset) {
    _readPositionController.updateReadPositions(
      "web/${widget.address.join("/")}",
      {"chapterId": _currentChapterId, "scroll": scrollOffset},
    );
  }

  @override
  void initState() {
    super.initState();
    _chapterOptionsController.reset();
    // 隐藏状态栏和导航栏（完全沉浸模式）
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [],
    );
    // 首次获取数据时, 不需要调用  _subbmitcurrentChapterId()
    _getChapterData(chapterId: widget.chapterId, isUpdateCI: false);

    // 第一次记录, 初始化
    _currentChapterId = widget.chapterId;

    final storageKey = "web/${widget.address.join("/")}";
    final savedChapterId =
        _readPositionController.readPositions[storageKey]?["chapterId"];

    if (savedChapterId != null && savedChapterId == widget.chapterId) {
      _scrollPosition =
          _readPositionController.readPositions[storageKey]?["scroll"] ?? 0.0;
    } else {
      _scrollPosition = 0.0;
    }

    _scrollController = ScrollController(initialScrollOffset: _scrollPosition);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    // 退出页面时恢复状态栏和导航栏
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values,
    );
    _hideTimer?.cancel();
    _chapterOptionsController.reset();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, bool? result) async {
        if (!didPop) {
          Navigator.pop(context, true); // 传递 true 作为返回值
        }
      },
      child: Obx(
        () => Scaffold(
          backgroundColor: _getBackgroundColor(),
          body: SafeArea(
            child: Stack(
              children: [
                // 主要内容（滚动阅读区域）
                GestureDetector(
                  onHorizontalDragStart: _handleHorizontalDragStart,
                  onHorizontalDragUpdate: _handleHorizontalDragUpdate,
                  onHorizontalDragEnd: _handleHorizontalDragEnd,
                  onTap: _controlsVisible ? _hideControls : _showControls,
                  behavior: HitTestBehavior.opaque,
                  child: _isLoading
                      ? LoadingWidght.showCommon()
                      : NovelText(
                          key: ValueKey(_currentChapterId),
                          novelData: _novelData,
                          scrollController: _scrollController,
                        ),
                ),
                // 顶部 AppBar（带透明度动画）
                if (_controlsVisible)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: AnimatedOpacity(
                      opacity: 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: AppBar(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _novelData.titleJp,
                              style: TextStyle(color: Colors.green),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (_novelData.titleZh.isNotEmpty)
                              Text(
                                _novelData.titleZh,
                                style: TextStyle(color: Colors.grey[600]),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                        backgroundColor: _getBackgroundColor(),
                        // elevation: _controlsVisible ? 4 : 0,
                        elevation: 0, // 始终无阴影
                        scrolledUnderElevation: 0, // 滚动时也不增加阴影
                        actions: [
                          Obx(
                            () => GestureDetector(
                              onTap: () => settings.updateIsTraditional(),
                              child: Chip(
                                label: Text(
                                  settings.isTraditional.value ? '繁' : '简',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                shape: CircleBorder(
                                  side: BorderSide(color: Colors.grey),
                                ),
                                padding: EdgeInsets.all(8), // 调整内边距使文字居中
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // 底部控制栏
                if (_controlsVisible)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: _cancelAutoHide,
                      child: AnimatedOpacity(
                        opacity: 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: BottomOptionBar(
                          // 上下章切换函数
                          changeChapter: (String direction) =>
                              _changeChapter(direction),
                          // 取消自动隐藏bar函数
                          cancelAutoHide: _cancelAutoHide,
                          // 列表页点击跳转函数
                          jumpToChapter: (String chapterId) {
                            // print(_currentChapterGlobalIndex);
                            _getChapterData(chapterId: chapterId);
                          },
                          adress: widget.address,
                          toc: widget.toc,
                          currentIndex: _currentChapterGlobalIndex,
                          color: _getBackgroundColor(),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
