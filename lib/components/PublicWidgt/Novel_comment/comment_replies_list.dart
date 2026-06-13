import 'package:flutter/material.dart';
import 'package:ailevon/components/PublicWidgt/Novel_comment/replies_item.dart';
import 'package:ailevon/viewmodels/comment.dart';

class CommentRepliesList extends StatefulWidget {
  final Comment comment;
  const CommentRepliesList({super.key, required this.comment});

  @override
  State<CommentRepliesList> createState() => _CommentRepliesListState();
}

class _CommentRepliesListState extends State<CommentRepliesList> {
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, sheetScrollController) {
        return ListView.builder(
          itemCount: 1 + widget.comment.replies.length,
          itemBuilder: (context, index) {
            if (index == 0) {
              return RepliesItem(comment: widget.comment, isOne: true);
            } else {
              return RepliesItem(comment: widget.comment.replies[index - 1]);
            }
          },
        );
      },
    );
  }
}
