import 'package:flutter/material.dart';
import 'package:ailevon/components/ReadHistory/web_read_history_item.dart';
import 'package:ailevon/viewmodels/web.dart';

class WebReadHistory extends StatefulWidget {
  final List<WebNovelItem> webNovelList;
  final Function? refFunction;
  const WebReadHistory({
    super.key,
    required this.webNovelList,
    this.refFunction,
  });

  @override
  State<WebReadHistory> createState() => _WebReadHistoryState();
}

class _WebReadHistoryState extends State<WebReadHistory> {
  @override
  Widget build(BuildContext context) {
    return SliverList.separated(
      itemBuilder: (context, index) {
        return RepaintBoundary(
          child: WebReadHistoryItem(
            item: widget.webNovelList[index],
            refFunction: widget.refFunction,
          ),
        );
      },
      separatorBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Divider(),
        );
      },
      itemCount: widget.webNovelList.length,
    );
  }
}
