import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ailevon/components/WebNovelDetails/web_half_chaper_list.dart';
import 'package:ailevon/constants/constants.dart';
import 'package:ailevon/pages/WebRead/novel_reader_page.dart';
import 'package:ailevon/stores/user_controller.dart';
import 'package:ailevon/stores/web_download_controller.dart';
import 'package:ailevon/utils/dio_request.dart';
import 'package:ailevon/utils/widget/settingwebdownload_dialog.dart';
import 'package:ailevon/utils/widget/download_dialog.dart';
import 'package:ailevon/utils/widget/toast_utils.dart';
import 'package:ailevon/utils/Function/updatetime.dart';
import 'package:ailevon/viewmodels/webdetails.dart';

class WebDetailHalf1 extends StatefulWidget {
  final List address;
  final WebNovelDetails webNovel;
  final Function? refFunction;
  const WebDetailHalf1({
    super.key,
    required this.address,
    required this.webNovel,
    this.refFunction,
  });

  @override
  State<WebDetailHalf1> createState() => _WebDetailHalf1State();
}

class _WebDetailHalf1State extends State<WebDetailHalf1> {
  // 获取用户共享参数
  final UserController _userController = Get.find();
  // 获取web下载设置共享的参数
  final _webDownloadController = Get.find<WebDownloadController>();
  bool _isFavored = false; // 是否收藏, 默认为否

  // 当前阅读章节的 globalIndex
  int? _currentChapterGlobalIndex;

  // lastReadChapter章节信息
  Map _lastReadChapterIdInfo = {};

  // 记录大chapter数量
  int _bigChapterNum = 0;

  void _dividerChapter() {
    for (var item in widget.webNovel.toc) {
      // 通过判断有没有chapterId,区分大小章节
      if (item["chapterId"] == null) {
        // +1
        _bigChapterNum++;
      }
    }
  }

  // 获取观看章节在列表目录的索引
  int _getGlobalIndexFromToc(String chapterId) {
    int idx = 0;
    for (var item in widget.webNovel.toc) {
      if (item['chapterId'] != null) {
        if (item['chapterId'].toString() == chapterId) return idx;
        idx++;
      }
    }
    return 0;
  }

  void _getlastReadChapterIdInfo() {
    late Map firstChapter;
    for (var item in widget.webNovel.toc) {
      if (item["chapterId"] != null) {
        firstChapter = item;
        break;
      }
    }
    if (widget.webNovel.lastReadChapterId != null &&
        widget.webNovel.lastReadChapterId!.isNotEmpty) {
      for (var item in widget.webNovel.toc) {
        if (item["chapterId"] == widget.webNovel.lastReadChapterId) {
          _lastReadChapterIdInfo = item;
        }
      }
    } else {
      _lastReadChapterIdInfo = firstChapter;
    }
  }

  // 统一按钮样式
  final ButtonStyle buttonStyle = TextButton.styleFrom(
    foregroundColor: Colors.white,
    backgroundColor: Colors.green,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
  );

  // 1 返回对应按扭组件
  Widget _getButtonRow() {
    return Wrap(
      spacing: 10,
      direction: Axis.horizontal,
      runSpacing: 10,
      children: [
        // 阅读按扭
        TextButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => NovelReaderPage(
                  address: widget.address,
                  chapterId: _lastReadChapterIdInfo["chapterId"],
                  toc: widget.webNovel.toc,
                ),
              ),
            );
            if (result == true) {
              widget.refFunction!();
            }
          },
          style: buttonStyle,
          child: Text(
            widget.webNovel.lastReadChapterId != null ? "继续阅读" : "开始阅读",
          ),
        ),
        //
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
                    "${HttpConstants.FAVORED_WEB}/${widget.address.join("/")}",
                  );
                } else {
                  await dioRequest.dioDelete(
                    "${HttpConstants.FAVORED_WEB}/${widget.address.join("/")}",
                  );
                }
              } catch (e) {
                setState(() {
                  _isFavored = oldFavored;
                });
                ToastUtils2.showToast("操作失败, 请稍后重试");
              }
            } else {
              ToastUtils2.showToast("未登录, 长按收藏前往登录");
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
        // 文库按扭
        if (widget.webNovel.wenkuId != null &&
            widget.webNovel.wenkuId!.isNotEmpty)
          TextButton(
            onPressed: () => Navigator.pushNamed(
              context,
              "/wenkunoveldetails?id=${Uri.encodeComponent("${widget.webNovel.wenkuId}")}",
            ),
            style: buttonStyle,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [Icon(Icons.book_outlined), Text("文库")],
            ),
          ),
      ],
    );
  }

  // 2 返回统计信息组件
  // 判断 统计信息是否为空和小于1k
  String _getIsOverK(int num) {
    if (num > 1000) {
      return "${(num / 1000).toStringAsFixed(1)}k";
    } else if (num >= 0) {
      return "$num";
    }
    return "0";
  }

  Widget _getStatistics() {
    return Text(
      "${widget.webNovel.type} / ${_getIsOverK(widget.webNovel.points)} PT / ${_getIsOverK(widget.webNovel.totalCharacters)} 字 / ${_getIsOverK(widget.webNovel.visited)} 浏览",
    );
  }

  // 3 返回可搜索标题,作者文本组件
  Widget _getSearchText() {
    return Wrap(
      children: [
        Text(
          widget.webNovel.toc.last["createAt"] != null
              ? "最近更新于 ${formartDate(widget.webNovel.toc.last["createAt"])} / "
              : "",
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              "/websearch",
              arguments: {"title": widget.webNovel.titleJp},
            );
          },
          child: Text("搜索标题", style: TextStyle(color: Colors.green)),
        ),
        Text(" / "),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              "/websearch",
              arguments: {"author": '"${widget.webNovel.authors[0]["name"]}"'},
            );
          },
          child: Text("搜索作者", style: TextStyle(color: Colors.green)),
        ),
      ],
    );
  }

  // 4 返回可点击的标签组件
  Widget _getNovelTags(List<String> list, List<String> list2) {
    List<String> listAll = [];
    listAll.addAll(list);
    listAll.addAll(list2);
    int count = 0;
    var tagWidgetList = listAll.map((tag) {
      count++;
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
              "/websearch",
              arguments: {"tag": '$tag\$'},
            );
          },
          child: Text(
            tag,
            style: TextStyle(
              color: Colors.black,
              fontWeight: count <= list.length
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ),
      );
    }).toList();
    // 返回Wrap
    return Wrap(
      spacing: 10,
      direction: Axis.horizontal,
      runSpacing: 10,
      children: tagWidgetList,
    );
  }

  // 5 章节数和翻译章节数组件
  Widget _getChaptersInfo() {
    return Text(
      "总计 ${widget.webNovel.toc.length - _bigChapterNum} / 百度 ${widget.webNovel.baidu} / 有道 ${widget.webNovel.youdao} / GPT ${widget.webNovel.gpt} / sukura ${widget.webNovel.sakura}",
    );
  }

  // 6 返回下载相关按扭组件
  Widget _getdownloadButton() {
    return Wrap(
      spacing: 10,
      direction: Axis.horizontal,
      runSpacing: 10,
      children: [
        TextButton(
          onPressed: () {
            // 弹出下载设置框
            SettingWebDownloadDialog.show(context);
          },
          style: buttonStyle,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [Icon(Icons.settings), Text("下载设置")],
          ),
        ),
        TextButton(
          onPressed: () async {
            // 获取原文下载请求
            try {
              // 文件名是否选择为中文
              bool isChinese =
                  _webDownloadController.webDownload["downloadFilenameType"] ==
                  "zh";

              String fileName = isChinese
                  ? "jp.${widget.webNovel.titleZh}.${_webDownloadController.webDownload["type"]}"
                  : "jp.${widget.webNovel.titleJp}.${_webDownloadController.webDownload["type"]}";

              // 下载设置参数拼接
              // 构建参数（原始中文）
              final params = {
                'mode': _webDownloadController.webDownload["mode"],
                'translationsMode':
                    _webDownloadController.webDownload["translationsMode"],
                'type': _webDownloadController.webDownload["type"],
                'filename': fileName,
              };
              // 构建相对路径（Uri 会自动编码）
              final uri = Uri(
                path:
                    '${HttpConstants.NOVEL_WEB}/${widget.address.join("/")}/file',
                queryParameters: params,
              );
              final relativePath = uri.toString();
              // 发送下载请求
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (dialogContext) {
                  return DownloadProgressDialog(
                    url: relativePath,
                    fileName: fileName,
                    onDownload: (progressCallback) async {
                      // 执行实际的下载，传入进度回调
                      await dioRequest.downloadFile(
                        url: relativePath,
                        fileName: fileName,
                        onReceiveProgress: progressCallback,
                      );
                    },
                  );
                },
              );
            } catch (e) {
              if (mounted) {
                // print(e);
                ToastUtils2.showToast("下载请求失败");
              }
            }
          },
          style: buttonStyle,
          child: Text("下载原文"),
        ),
        TextButton(
          onPressed: () async {
            // 获取翻译下载请求
            try {
              // 文件名是否选择为中文
              bool isChinese =
                  _webDownloadController.webDownload["downloadFilenameType"] ==
                  "zh";
              // 翻译类型存在方式是否为优先
              bool isYouxian =
                  _webDownloadController.webDownload["translationsMode"] ==
                  "priority";
              // 获取下载语言
              String yuyan = _webDownloadController.webDownload["mode"];
              // 获取翻译顺序参数
              String translations = _webDownloadController
                  .webDownload["translations"]
                  .map((s) => s.isNotEmpty ? s[0] : '')
                  .toList()
                  .join();
              // 获取下载文件类型
              String type = _webDownloadController.webDownload["type"];
              // 依据判断, 设置翻译类型存在方式
              String yORb = isYouxian ? "Y" : "B";
              // 依据判断, 设置下载文件名(字符串)
              String fileName = isChinese
                  ? "$yuyan.$yORb$translations.${widget.webNovel.titleZh}.$type"
                  : "$yuyan.$yORb$translations.${widget.webNovel.titleJp}.$type";

              // 下载设置参数拼接
              // 构建参数（原始中文）
              final params = {
                'mode': _webDownloadController.webDownload["mode"],
                'translationsMode':
                    _webDownloadController.webDownload["translationsMode"],
                'type': _webDownloadController.webDownload["type"],
                'filename': fileName,
                'translations':
                    (_webDownloadController.webDownload["translations"])
                        .cast<String>(),
              };

              // 构建相对路径（Uri 会自动编码）
              final uri = Uri(
                path:
                    '${HttpConstants.NOVEL_WEB}/${widget.address.join("/")}/file',
                queryParameters: params,
              );
              final relativePath = uri.toString();
              // 发送下载请求
              // 发送下载请求
              showDialog(
                context: context,
                // barrierDismissible: false,
                builder: (dialogContext) {
                  return DownloadProgressDialog(
                    url: relativePath,
                    fileName: fileName,
                    onDownload: (progressCallback) async {
                      // 执行实际的下载，传入进度回调
                      await dioRequest.downloadFile(
                        url: relativePath,
                        fileName: fileName,
                        onReceiveProgress: progressCallback,
                      );
                    },
                  );
                },
              );
            } catch (e) {
              if (mounted) {
                // print(e);
                ToastUtils2.showToast("下载请求失败");
              }
            }
          },
          style: buttonStyle,
          child: Text("下载机翻"),
        ),
      ],
    );
  }

  // 当前章节和展开章节组件
  Widget _getCurrentChapter() {
    return Column(
      children: [
        ListTile(
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          dense: true,
          splashColor: Colors.transparent,
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => NovelReaderPage(
                  address: widget.address,
                  chapterId: _lastReadChapterIdInfo["chapterId"],
                  toc: widget.webNovel.toc,
                ),
              ),
            );
            if (result == true) {
              widget.refFunction!();
            }
          },
          title: Text.rich(
            TextSpan(
              text: "${_lastReadChapterIdInfo["titleJp"] ?? ""}\n",
              style: TextStyle(
                color: widget.webNovel.lastReadChapterId != null
                    ? Colors.amber
                    : Colors.green,
              ),
              children: [
                TextSpan(
                  text: "${_lastReadChapterIdInfo["titleZh"] ?? ""}",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          subtitle: Text(
            "[${widget.webNovel.lastReadChapterId != null ? _currentChapterGlobalIndex : 0}]  ${_lastReadChapterIdInfo["createAt"] != null ? formartDateHM(_lastReadChapterIdInfo["createAt"]) : ''}",
          ),
        ),
        TextButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => WebHalfChaperList(
                toc: widget.webNovel.toc,
                address: widget.address,
                currentChapterIndex: _currentChapterGlobalIndex,
                refFunction: widget.refFunction!,
              ),
            );
          },
          style: ButtonStyle(
            foregroundColor: WidgetStateProperty.all(Colors.black),
            // 背景色
            backgroundColor: WidgetStateProperty.all(Colors.grey[300]),
            overlayColor: WidgetStateProperty.resolveWith<Color?>((
              Set<WidgetState> states,
            ) {
              return Theme.of(context).splashColor; // 改变按压时的背景颜色
            }), // 按压颜色
          ),
          child: Center(child: Text("展开目录")),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    // 根据外部数据初始化收藏状态
    _isFavored = widget.webNovel.favored != null;
    _dividerChapter();
    if (widget.webNovel.lastReadChapterId != null) {
      _currentChapterGlobalIndex = _getGlobalIndexFromToc(
        widget.webNovel.lastReadChapterId!,
      );
    }
    _getlastReadChapterIdInfo();
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.only(left: 20, right: 20, bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.webNovel.titleJp,
                  style: TextStyle(color: Colors.green, fontSize: 20),
                ),
                Text(widget.webNovel.titleZh, style: TextStyle(fontSize: 20)),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              "作者: ${widget.webNovel.authors.isNotEmpty ? widget.webNovel.authors[0]["name"] : ""}",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 15),
            // 文本按扭组件
            _getButtonRow(),
            const SizedBox(height: 8),
            Divider(color: Colors.grey),
            // 统计信息文本
            _getStatistics(),
            const SizedBox(height: 8),
            // 搜索标题,作者文本组件
            _getSearchText(),
            const SizedBox(height: 15),
            // 搜索标签组件
            _getNovelTags(widget.webNovel.attentions, widget.webNovel.keywords),
            const SizedBox(height: 15),
            // 章节和翻译章节组件
            _getChaptersInfo(),
            const SizedBox(height: 8),
            // 下载按扭组件
            _getdownloadButton(),
            const SizedBox(height: 8),
            Divider(color: Colors.grey),
            _getCurrentChapter(),
          ],
        ),
      ),
    );
  }
}
