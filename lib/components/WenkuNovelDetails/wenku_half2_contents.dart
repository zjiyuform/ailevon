import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ailevon/constants/constants.dart';
import 'package:ailevon/stores/user_controller.dart';
import 'package:ailevon/stores/web_download_controller.dart';
import 'package:ailevon/utils/dio_reqeust.dart';
import 'package:ailevon/utils/widget/download_dialog.dart';
import 'package:ailevon/utils/Function/sort_wenku_volumes.dart';
import 'package:ailevon/utils/widget/toast_utils.dart';

class WenkuHalf2Contents extends StatefulWidget {
  final String id;
  final List<Map<String, dynamic>> volumeJp;
  // final String title;
  final ScrollController? scrollController;
  const WenkuHalf2Contents({
    super.key,
    required this.id,
    // required this.title,
    required this.volumeJp,
    this.scrollController,
  });

  @override
  State<WenkuHalf2Contents> createState() => _WenkuHalf2ContentsState();
}

class _WenkuHalf2ContentsState extends State<WenkuHalf2Contents> {
  // 获取web下载设置共享的参数
  final _webDownloadController = Get.find<WebDownloadController>();
  final UserController _userController = Get.find();

  Widget _getContentItem(Map item) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item["volumeId"]),
              const SizedBox(height: 6),
              Text(
                "总计 ${item["total"]} / 百度 ${item["baidu"]} / 有道 ${item["youdao"]} / GPT ${item["gpt"]} / Sakura ${item["sakura"]}",
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        TextButton(
          onPressed: () async {
            // print(item["volumeId"]);
            try {
              // 获取下载语言
              String yuyan = _webDownloadController.webDownload["mode"];
              // 依据判断, 设置翻译类型存在方式
              String yORb =
                  _webDownloadController.webDownload["translationsMode"] ==
                      "priority"
                  ? "Y"
                  : "B";
              // 获取翻译顺序参数
              String translations = _webDownloadController
                  .webDownload["translations"]
                  .map((s) => s.isNotEmpty ? s[0] : '')
                  .toList()
                  .join();

              String fileName = "$yuyan.$yORb$translations.${item["volumeId"]}";
              // 下载设置参数拼接
              // 构建参数（原始中文）
              final params = {
                'mode': _webDownloadController.webDownload["mode"],
                'translationsMode':
                    _webDownloadController.webDownload["translationsMode"],
                'filename': fileName,
                'translations':
                    (_webDownloadController.webDownload["translations"])
                        .cast<String>(),
              };
              // 构建相对路径（Uri 会自动编码）
              final uri = Uri(
                path:
                    '${HttpConstants.NOVEL_WENKU}/${widget.id}/file/${item["volumeId"]}',
                queryParameters: params,
              );
              final relativePath = uri.toString();
              // 发送下载请求
              showDialog(
                context: context,
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
                _webDownloadController.webDownload["translations"].length < 1
                    ? ToastUtils2.showToast("需要选择至少一个翻译源")
                    : ToastUtils2.showToast("下载请求失败");
              }
            }
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [Icon(Icons.download), Text("下载")],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return _userController.user.value.username.isNotEmpty
          ? widget.volumeJp.isNotEmpty
                ? CustomScrollView(
                    slivers: [
                      // 间隔区域
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const SizedBox(height: 10),
                        ),
                      ),
                      // 下载目录区域
                      SliverList.separated(
                        itemCount: widget.volumeJp.length,
                        itemBuilder: (context, index) {
                          return Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.only(
                              left: 20,
                              right: 20,
                              top: 7,
                            ),
                            child: _getContentItem(
                              sortVolumesDetailed(widget.volumeJp)[index],
                            ),
                          );
                        },
                        separatorBuilder: (context, index) => const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Divider(),
                        ),
                      ),

                      SliverToBoxAdapter(child: const SizedBox(height: 50)),
                    ],
                  )
                : CustomScrollView(
                    slivers: [
                      SliverFillRemaining(child: Center(child: Text("暂无下载内容"))),
                    ],
                  )
          : CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  child: Center(child: Text("未登录, 长按收藏或下载设置前往登录")),
                ),
              ],
            );
    });
  }
}
