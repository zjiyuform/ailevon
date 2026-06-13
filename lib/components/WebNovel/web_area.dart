import 'package:flutter/material.dart';
import 'package:ailevon/utils/Function/updatetime.dart';
import 'package:ailevon/viewmodels/web.dart';

class WebMainArea extends StatefulWidget {
  // final WebPageJson webPageJson;
  final List<WebNovelItem> webNovelList;
  const WebMainArea({super.key, required this.webNovelList});

  @override
  State<WebMainArea> createState() => _WebMainAreaState();
}

class _WebMainAreaState extends State<WebMainArea> {
  List<TextSpan> _getNovelTagsText(List<String> list, List<String> list2) {
    return [
      TextSpan(
        text: list.join(" / "),
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[600]),
      ),
      list.isNotEmpty
          ? TextSpan(
              text: " / ",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            )
          : TextSpan(text: ""),
      TextSpan(
        text: list2.join(" / "),
        style: TextStyle(
          fontWeight: FontWeight.normal,
          color: Colors.grey[600],
        ),
      ),
    ];
  }

  // 返回webItem项方法
  Widget _buildItem(int index) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                final providerId = widget.webNovelList[index].providerId;
                final novelId = widget.webNovelList[index].novelId;
                final routeName =
                    "/webnoveldetails?provider=${Uri.encodeComponent(providerId)}&novelId=${Uri.encodeComponent(novelId)}";
                Navigator.pushNamed(context, routeName);
                // Navigator.pushNamed(
                //   context,
                //   "/webnoveldetails",
                //   arguments: [
                //     widget.webNovelList[index].providerId,
                //     widget.webNovelList[index].novelId,
                //   ],
                // );
              },
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.webNovelList[index].titleJp,
                      style: TextStyle(color: Colors.green),
                    ),
                    Text(widget.webNovelList[index].titleZh),
                  ],
                ),
              ),
            ),
            Text(
              "${widget.webNovelList[index].providerId}.${widget.webNovelList[index].novelId}",
            ),
            Text.rich(
              TextSpan(
                children: _getNovelTagsText(
                  widget.webNovelList[index].attentions,
                  widget.webNovelList[index].keywords,
                ),
              ),
            ),
            Text(
              "${widget.webNovelList[index].type} / 总计 ${widget.webNovelList[index].total} / 百度 ${widget.webNovelList[index].baidu} / 有道 ${widget.webNovelList[index].youdao} / GPT ${widget.webNovelList[index].gpt} / sukura ${widget.webNovelList[index].sakura}",
            ),
            Text(
              "绿站更新于${formatTimeAgo(widget.webNovelList[index].updateAt)}",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SliverList.separated(
      itemBuilder: (context, index) {
        return RepaintBoundary(child: _buildItem(index));
      },
      separatorBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Divider(),
        );
      },
      itemCount: widget.webNovelList.length,
    );
  }
}
