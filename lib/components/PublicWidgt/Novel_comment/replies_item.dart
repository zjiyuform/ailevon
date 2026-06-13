import 'package:flutter/material.dart';
import 'package:ailevon/utils/Function/remove_textmd.dart';
import 'package:ailevon/utils/Function/updatetime.dart';
import 'package:ailevon/viewmodels/comment.dart';

class RepliesItem extends StatefulWidget {
  final Comment comment;
  final bool isOne;
  const RepliesItem({super.key, required this.comment, this.isOne = false});

  @override
  State<RepliesItem> createState() => _RepliesItemState();
}

class _RepliesItemState extends State<RepliesItem> {
  bool _expanded = false; // true: 全部展开, false: 最多6行

  /// 判断文本是否超过指定行数
  bool _isTextExceedingLines(
    String text,
    TextStyle style,
    double maxWidth,
    int maxLines,
  ) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: maxLines,
    )..layout(maxWidth: maxWidth);
    return painter.didExceedMaxLines;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textMaxWidth = screenWidth - 60; // 左右 padding 各 30
    final textStyle = TextStyle(fontSize: 16);
    final content = widget.comment.content;

    // 只有内容超过 6 行时才显示按钮
    final bool exceedsSixLines = content.isNotEmpty
        ? _isTextExceedingLines(content, textStyle, textMaxWidth, 6)
        : false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundImage: AssetImage("lib/assets/avatar/default_avatar.png"),
            backgroundColor: Colors.white,
          ),
          title: Text("${widget.comment.user['username']}"),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                parseToPlainText(content),
                maxLines: _expanded ? 999 : 6, // 展开时 999行数, 收起时最多6行
                overflow: TextOverflow.ellipsis,
                style: textStyle,
              ),
              if (exceedsSixLines)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _expanded = !_expanded; // 切换展开/收起状态
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      _expanded ? "收起" : "展开全部", // B 方案: 展开按钮文字变化
                      style: const TextStyle(color: Colors.green, fontSize: 14),
                    ),
                  ),
                ),
              const SizedBox(height: 5),
              Text(
                formatTimeAgo(widget.comment.createAt),
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        widget.isOne
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 10, color: Colors.grey[300]),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const SizedBox(width: 20),
                      Text(
                        "相关回复共 ${widget.comment.replies.length} 条",
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                ],
              )
            : const Padding(
                padding: EdgeInsetsGeometry.symmetric(horizontal: 20),
                child: Divider(),
              ),
      ],
    );
  }
}
