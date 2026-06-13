import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ailevon/components/PublicWidgt/avatar.dart';
import 'package:ailevon/constants/constants.dart';
import 'package:ailevon/pages/ReadHistory/read_history_body.dart';
import 'package:ailevon/pages/ReadHistory/store/record_controller.dart';
import 'package:ailevon/stores/user_controller.dart';
import 'package:ailevon/utils/dio_reqeust.dart';
import 'package:ailevon/utils/widget/toast_utils.dart';

class ReadHistoryView extends StatefulWidget {
  // 接收父组件传递的 ScrollController, 用于实现点击底部tap时,触发滚动事件
  final ScrollController? controller;
  const ReadHistoryView({super.key, this.controller});

  @override
  State<ReadHistoryView> createState() => _ReadHistoryViewState();
}

class _ReadHistoryViewState extends State<ReadHistoryView> {
  final UserController _userController = Get.find();
  // 用于调用子组件传递的方法
  Function? _refbodyFn;
  bool _isDeleteLoading = false;

  final RecordController _recordController = Get.find<RecordController>();
  bool _isSwitchLoading = false;

  // 获取页面body方法
  Widget _getChilden(ScrollController? controller) {
    if (_userController.user.value.username.isNotEmpty) {
      return ReadHistoryBody(
        controller: controller,
        subbmitRef: (Function fn) {
          _refbodyFn = fn;
        },
      );
    } else {
      return CustomScrollView(
        controller: controller,
        slivers: [
          SliverFillRemaining(child: Center(child: Text("未登录, 点击左上角登录"))),
        ],
      );
    }
  }

  // 发送删除请求
  Future<void> _sendDeleteRequest() async {
    setState(() {
      _isDeleteLoading = true;
    });
    try {
      await dioRequest.dioDelete(HttpConstants.READHISTORY);
    } catch (e) {
      // 请求异常处理
      ToastUtils2.showToast("删除失败");
    } finally {
      //
      if (mounted) {
        setState(() {
          _isDeleteLoading = false;
        });
      }
    }
  }

  // 弹出删除提醒框
  Future<dynamic> _showAlert() {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("提示"),
          content: Text("确认清空记录吗"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("取消", style: TextStyle(color: Colors.green)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                if (_refbodyFn != null) {
                  await _sendDeleteRequest();
                  await _refbodyFn!();
                  ToastUtils2.showToast("删除成功");
                }
              },
              child: Text("确认", style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

  // 发送暂停/开启记录请求
  Future<void> _sendPausedRequest({bool flag = true}) async {
    setState(() {
      _isSwitchLoading = true;
    });
    try {
      flag
          ? await dioRequest.dioPut("${HttpConstants.READHISTORY}/paused")
          : await dioRequest.dioDelete("${HttpConstants.READHISTORY}/paused");

      // 更新recordController.isPaused 的值
      await _recordController.getIsPaused();
    } catch (e) {
      // 请求异常处理
      ToastUtils2.showToast("切换失败");
    } finally {
      //
      if (mounted) {
        setState(() {
          _isSwitchLoading = false;
        });
      }
    }
  }

  Widget _getRecordButton() {
    if (_userController.user.value.username.isNotEmpty) {
      return _isSwitchLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                color: Colors.green,
              ),
            )
          : _recordController.isPaused.value
          ? IconButton(
              onPressed: () {
                _sendPausedRequest(flag: false);
              },
              icon: Icon(Icons.sensors_off),
            )
          : IconButton(
              onPressed: () {
                _sendPausedRequest(flag: true);
              },
              icon: Icon(Icons.sensors),
            );
    }
    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverOverlapAbsorber(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: SliverAppBar(
              pinned: true,
              title: Text("阅读历史"),
              centerTitle: true,
              leading: Builder(
                // Builder 用来获取正确的 Scaffold 上下文，否则无法打开抽屉
                builder: (context) => IconButton(
                  icon: PubAvatar(),
                  // 点击头像打开抽屉，和原菜单按钮功能一致
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              actions: [
                Obx(() => _getRecordButton()),
                IconButton(
                  onPressed: () async {
                    if (_userController.user.value.username.isNotEmpty) {
                      await _showAlert();
                    }
                  },
                  icon: _isDeleteLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            color: Colors.green,
                          ),
                        )
                      : Icon(Icons.delete),
                ),
                const SizedBox(width: 10),
              ],
            ),
          ),
        ];
      },
      body: Obx(() => _getChilden(widget.controller)),
    );
  }
}
