import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:ailevon/utils/Function/updatetime.dart';
import 'package:ailevon/viewmodels/web.dart';

class HomeWeb extends StatefulWidget {
  //
  final List<WebNovelItem> webNovelList; // 定义接收属性
  const HomeWeb({super.key, required this.webNovelList});

  @override
  State<HomeWeb> createState() => _HomeWebState();
}

class _HomeWebState extends State<HomeWeb> {
  @override
  Widget build(BuildContext context) {
    Widget getListItems(int index) {
      return Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 30),
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
            const SizedBox(height: 5),
            Text(
              "${widget.webNovelList[index].type} / 总计 ${widget.webNovelList[index].total} / 百度 ${widget.webNovelList[index].baidu} / 有道 ${widget.webNovelList[index].youdao} / GPT ${widget.webNovelList[index].gpt} / sukura ${widget.webNovelList[index].sakura}",
            ),
            Text(
              "绿站更新于${formatTimeAgo(widget.webNovelList[index].updateAt)}",
              style: TextStyle(color: Colors.grey[600]),
            ),
            Divider(),
          ],
        ),
      );
    }

    // SliverGrid, SliverList 只能纵向排列
    return SliverList.builder(
      itemBuilder: (context, index) {
        if (widget.webNovelList.isEmpty) {
          return Skeletonizer(
            enabled: true,
            child: _placeholder(), // 提供一个空壳模型
          );
        }
        return getListItems(index);
      },
      itemCount: 6,
    );
  }
}

Widget _placeholder() {
  return Card(
    child: ListTile(
      title: Text('The title goes here The title goes here'),
      subtitle: Text('Subtitle here Subtitle here'),
      trailing: Skeleton.ignore(
        // the icon will not be skeletonized
        child: Icon(Icons.ac_unit, size: 40),
      ),
    ),
  );
}
