// 独立的列表项组件，管理自己的删除加载状态
import 'package:flutter/material.dart';
import 'package:ailevon/constants/constants.dart';
import 'package:ailevon/utils/dio_reqeust.dart';
import 'package:ailevon/utils/widget/toast_utils.dart';
import 'package:ailevon/utils/Function/updatetime.dart';
import 'package:ailevon/viewmodels/web.dart';

class WebReadHistoryItem extends StatefulWidget {
  final WebNovelItem item;
  final Function? refFunction;
  const WebReadHistoryItem({super.key, required this.item, this.refFunction});

  @override
  State<WebReadHistoryItem> createState() => _WebReadHistoryItemState();
}

class _WebReadHistoryItemState extends State<WebReadHistoryItem> {
  bool _isLoading = false;

  Future<void> _sendDeleteRequest(List<String> address) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await dioRequest.dioDelete(
        "${HttpConstants.READHISTORY}/${address.join("/")}",
      );
    } catch (e) {
      // 请求异常处理
      ToastUtils2.showToast("删除失败");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              final providerId = widget.item.providerId;
              final novelId = widget.item.novelId;
              final routeName =
                  "/webnoveldetails?provider=${Uri.encodeComponent(providerId)}&novelId=${Uri.encodeComponent(novelId)}";
              Navigator.pushNamed(context, routeName);
            },
            child: SizedBox(
              width: double.infinity,
              child: Text.rich(
                TextSpan(
                  text: "${widget.item.titleJp}\n",
                  style: TextStyle(color: Colors.green),
                  children: [TextSpan(text: widget.item.titleZh)],
                ),
              ),
            ),
          ),
          Text(
            "${widget.item.type} / 总计 ${widget.item.total} / 百度 ${widget.item.baidu} / 有道 ${widget.item.youdao} / GPT ${widget.item.gpt} / sukura ${widget.item.sakura}",
          ),
          Text(
            "绿站更新于${formatTimeAgo(widget.item.updateAt)} / ${widget.item.lastReadAt != null ? '${formatTimeAgo(widget.item.lastReadAt!)} 看过 /' : ''}",
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 5),
          TextButton(
            onPressed: () async {
              if (!_isLoading) {
                await _sendDeleteRequest([
                  widget.item.providerId,
                  widget.item.novelId,
                ]);
                widget.refFunction!();
              }
            },
            style: ButtonStyle(
              side: WidgetStateProperty.all(
                BorderSide(color: Colors.grey, width: 0.5),
              ),
            ),
            child: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      color: Colors.green,
                    ),
                  )
                : Text("删除", style: TextStyle(color: null)),
          ),
        ],
      ),
    );
  }
}
