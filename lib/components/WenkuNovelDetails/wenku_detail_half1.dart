import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ailevon/constants/constants.dart';
import 'package:ailevon/stores/user_controller.dart';
import 'package:ailevon/utils/dio_reqeust.dart';
import 'package:ailevon/utils/widget/settingwebdownload_dialog.dart';
import 'package:ailevon/utils/widget/toast_utils.dart';
import 'package:ailevon/utils/Function/updatetime.dart';
import 'package:ailevon/viewmodels/wenkudetails.dart';

class WenkuDetailHalf1 extends StatefulWidget {
  final WenkuNovelDetails wenkuNovel;
  final String id;
  final Function? refFunction;
  const WenkuDetailHalf1({
    super.key,
    required this.wenkuNovel,
    required this.id,
    this.refFunction,
  });

  @override
  State<WenkuDetailHalf1> createState() => _WenkuDetailHalf1State();
}

class _WenkuDetailHalf1State extends State<WenkuDetailHalf1> {
  // 获取用户共享参数
  final UserController _userController = Get.find();

  bool _isFavored = false; // 是否收藏, 默认为否

  // 1 获取出版信息区域
  // 返回出版信息列表点击组件
  List<GestureDetector> _getPublishInfobtnList(List<String> infoList) {
    return infoList.map((item) {
      return GestureDetector(
        onTap: () {
          Navigator.pushNamed(
            context,
            "/wenkusearch",
            arguments: {"tag": '"$item"'},
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(item, style: TextStyle(color: Colors.white)),
        ),
      );
    }).toList();
  }

  // 返回出版信息可点击组件
  GestureDetector _getPublishInfobtn(String info) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          "/wenkusearch",
          arguments: {"tag": '"$info"'},
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(info, style: TextStyle(color: Colors.white)),
      ),
    );
  }

  // 返回出版信息区域组件
  Widget _getPublishInfo() {
    return SizedBox(
      // height: 260,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            fit: BoxFit.cover,
            height: 240,
            widget.wenkuNovel.cover,
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (frame == null) {
                // 正在加载，显示白色骨架
                return Container(
                  alignment: Alignment.center,
                  color: Colors.white,
                  width: 160,
                  height: 240,
                  child: Text("加载中"),
                );
              }
              // 加载完成，显示图片
              return child;
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 160,
                height: 240,
                alignment: Alignment.center,
                color: Colors.white,
                child: Text("加载失败"),
              );
            },
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.wenkuNovel.titleZh,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Divider(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 40, child: Text("作者:")),
                      // const SizedBox(width: 3),
                      widget.wenkuNovel.authors.isNotEmpty
                          ? Expanded(
                              child: Wrap(
                                spacing: 10,
                                runSpacing: 6,
                                children: _getPublishInfobtnList(
                                  widget.wenkuNovel.authors,
                                ),
                              ),
                            )
                          : Text(""),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 40, child: Text("画师:")),
                      widget.wenkuNovel.artists.isNotEmpty
                          ? Expanded(
                              child: Wrap(
                                spacing: 10,
                                runSpacing: 6,
                                children: _getPublishInfobtnList(
                                  widget.wenkuNovel.artists,
                                ),
                              ),
                            )
                          : Text(""),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 40, child: Text("出版:")),
                      Expanded(
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 6,
                          children: [
                            //
                            widget.wenkuNovel.publisher.isNotEmpty
                                ? _getPublishInfobtn(
                                    widget.wenkuNovel.publisher,
                                  )
                                : Text(""),
                            //
                            widget.wenkuNovel.imprint.isNotEmpty
                                ? _getPublishInfobtn(widget.wenkuNovel.imprint)
                                : Text(""),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 统一按钮样式
  final ButtonStyle buttonStyle = TextButton.styleFrom(
    foregroundColor: Colors.white,
    backgroundColor: Colors.green,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
  );

  // 2 返回对应按扭组件
  Widget _getButtonRow() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        // 收藏按扭
        TextButton(
          onPressed: () async {
            // 判断是否登录
            if (_userController.user.value.username.isNotEmpty) {
              // 保存旧状态
              final bool oldFavored = _isFavored;
              // 乐观更新：立即改变 UI
              setState(() {
                _isFavored = !_isFavored;
              });

              try {
                if (_isFavored) {
                  await dioRequest.dioPut(
                    "${HttpConstants.FAVORED_WENKU}/${widget.id}",
                  );
                } else {
                  await dioRequest.dioDelete(
                    "${HttpConstants.FAVORED_WENKU}/${widget.id}",
                  );
                }
              } catch (e) {
                setState(() {
                  _isFavored = oldFavored;
                });
                if (mounted) ToastUtils2.showToast("操作失败, 请稍后重试");
              }
            } else {
              ToastUtils2.showToast("未登录, 长按收藏或下载设置前往登录");
            }
          },
          onLongPress: () async {
            if (_userController.user.value.username.isEmpty) {
              final result = await Navigator.pushNamed(context, "/login");
              if (result == true && mounted) {
                widget.refFunction!();
              }
            }
          },
          style: buttonStyle,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: _isFavored
                ? [Icon(Icons.favorite), Text("已收藏")]
                : [Icon(Icons.favorite_border), Text("收藏")],
          ),
        ),
        //
        // 下载设置按扭
        TextButton(
          onPressed: () {
            // 弹出下载设置框
            SettingWebDownloadDialog.show(context, isWeb: false);
          },
          onLongPress: () async {
            if (_userController.user.value.username.isEmpty) {
              final result = await Navigator.pushNamed(context, "/login");
              if (result == true && mounted) {
                widget.refFunction!();
              }
            }
          },
          style: buttonStyle,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [Icon(Icons.settings), Text("下载设置")],
          ),
        ),
        //
        // web按扭
        if (widget.wenkuNovel.webIds.isNotEmpty)
          TextButton(
            onPressed: () {
              // 只获取第一个web路径
              List<String> parts = widget.wenkuNovel.webIds[0].split('/');
              final routeName =
                  "/webnoveldetails?provider=${Uri.encodeComponent(parts[0])}&novelId=${Uri.encodeComponent(parts[1])}";
              Navigator.pushNamed(context, routeName);
            },
            style: buttonStyle,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [Icon(Icons.web), Text("网络")],
            ),
          ),
      ],
    );
  }

  // 3 返回可点击的标签组件
  Widget _getNovelTags(List<String> list) {
    var tagWidgetList = list.map((tag) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(5),
        ),
        child: GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              "/wenkusearch",
              arguments: {"tag": '$tag\$'},
            );
          },
          child: Text(
            tag,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      );
    }).toList();
    // 返回Wrap
    return Wrap(spacing: 10, runSpacing: 6, children: tagWidgetList);
  }

  @override
  void initState() {
    super.initState();
    // 根据外部数据初始化收藏状态
    _isFavored = widget.wenkuNovel.favored != null;
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.only(left: 20, right: 20, bottom: 10),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // wenku出版信息组件
            _getPublishInfo(),
            const SizedBox(height: 20),
            // 文本按扭组件
            _getButtonRow(),
            const SizedBox(height: 8),
            // 原名文本组件
            Text("原名: ${widget.wenkuNovel.title}"),
            const SizedBox(height: 8),
            // 最新出版时间文本组件
            Text(
              "最新出版于 ${widget.wenkuNovel.latestPublishAt > 0 ? formartDate(widget.wenkuNovel.latestPublishAt) : ""} / 浏览量 ${widget.wenkuNovel.visited}",
            ),
            const SizedBox(height: 8),
            // 搜索标签组件
            _getNovelTags(widget.wenkuNovel.keywords),
            // 横向滑动文库系列组件
            const SizedBox(height: 15),
            SizedBox(
              height: 150, // 指定高度
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.wenkuNovel.volumes.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(right: 6),
                    child: Image.network(
                      "${(widget.wenkuNovel.volumes[index])["cover"]}",

                      frameBuilder:
                          (context, child, frame, wasSynchronouslyLoaded) {
                            if (frame == null) {
                              // 正在加载，显示白色骨架
                              return Container(
                                alignment: Alignment.center,
                                color: Colors.white,
                                width: 100,
                                height: 150,
                                child: Text("加载中"),
                              );
                            }
                            // 加载完成，显示图片
                            return child;
                          },
                      errorBuilder: (context, error, stackTrace) {
                        return SizedBox(
                          width: 100,
                          height: 150,
                          child: Text("加载失败", textAlign: TextAlign.center),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
