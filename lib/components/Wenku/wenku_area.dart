import 'package:flutter/material.dart';
import 'package:ailevon/viewmodels/wenku.dart';

class WenkuMainArea extends StatefulWidget {
  final List<WenkuNovelItem> wenkuNovelList; // 定义接收属性
  const WenkuMainArea({super.key, required this.wenkuNovelList});

  @override
  State<WenkuMainArea> createState() => _WenkuMainAreaState();
}

class _WenkuMainAreaState extends State<WenkuMainArea> {
  @override
  Widget build(BuildContext context) {
    // 在 flutter 获取屏幕宽高度的方法
    final double screenWidth = MediaQuery.of(context).size.width; // 屏幕宽度
    int count = 2;
    if (screenWidth > 900) {
      count = 6;
    } else if (screenWidth > 600) {
      count = 4;
    }

    // Grid的生成项 改写出成一个方法
    Widget getGridItems(int index) {
      return GestureDetector(
        onTap: () => Navigator.pushNamed(
          context,
          "/wenkunoveldetails?id=${Uri.encodeComponent(widget.wenkuNovelList[index].id)}",
        ),
        child: Column(
          children: [
            Expanded(
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Image.network(
                  fit: BoxFit.cover,
                  width: double.infinity, // 宽度充满
                  widget.wenkuNovelList[index].cover,
                  errorBuilder: (context, error, stackTrace) {
                    return SizedBox(
                      width: double.infinity,
                      child: Text('加载失败', textAlign: TextAlign.center),
                    );
                  },
                ),
              ),
            ),
            Container(
              height: 50,
              padding: EdgeInsets.only(left: 8, right: 8),
              child: Text(
                widget.wenkuNovelList[index].titleZh,
                // 设置最大显示行
                maxLines: 2,
                // 设置文本溢出, 时效果
                overflow: TextOverflow.ellipsis, // 显示 ...
              ),
            ),
          ],
        ),
      );
    }

    // SliverGrid, SliverList 只能纵向排列
    return SliverPadding(
      padding: const EdgeInsets.all(5), // 设置四周内边距
      sliver: SliverGrid.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: count,
          // mainAxisSpacing: 10,
          // crossAxisSpacing: 5,
          childAspectRatio: 0.6,
        ),
        itemBuilder: (BuildContext context, int index) {
          return getGridItems(index);
        },
        itemCount: widget.wenkuNovelList.length,
      ),
    );
  }
}
