import 'package:flutter/material.dart';
import 'package:ailevon/utils/Function/updatetime.dart';
import 'package:ailevon/viewmodels/comment.dart';
import 'package:ailevon/components/PublicWidgt/Novel_comment/comment_replies_list.dart';
import 'package:ailevon/utils/Function/remove_textmd.dart';

class CommentItem extends StatefulWidget {
  final Comment comment;

  const CommentItem({super.key, required this.comment});

  @override
  State<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
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

  /// 回复区域（使用 Text.rich 高亮用户名）
  Widget _buildReplies(Comment comment) {
    final replies = widget.comment.replies;
    if (replies.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(5),
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            // print("object");
            _showChapterList(comment);
          },
          child: Column(
            spacing: 5,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...replies.take(2).map((reply) {
                return Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${reply.user["username"]}: ',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      TextSpan(
                        text: parseToPlainText(reply.content),
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 16),
                );
              }),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "共${replies.length}条回复",
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      height: 1.15,
                    ),
                  ),
                  Icon(Icons.chevron_right, size: 16, color: Colors.green),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 弹出详细回复
  void _showChapterList(Comment comment) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      isScrollControlled: true,
      builder: (context) => CommentRepliesList(comment: comment),
    );
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
        _buildReplies(widget.comment),
        const Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 20),
          child: Divider(),
        ),
      ],
    );
  }
}
