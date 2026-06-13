import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:ailevon/viewmodels/wenku.dart';

class HomeWenku extends StatefulWidget {
  final List<WenkuNovelItem> wenkuNovelList; // 定义接收属性
  const HomeWenku({super.key, required this.wenkuNovelList});

  @override
  State<HomeWenku> createState() => _HomeWenkuState();
}

class _HomeWenkuState extends State<HomeWenku> {
  @override
  Widget build(BuildContext context) {
    // 在 flutter 获取屏幕宽高度的方法
    final double screenWidth = MediaQuery.of(context).size.width; // 屏幕宽度
    int count = 3;
    if (screenWidth > 900) {
      count = 6;
    } else if (screenWidth > 600) {
      count = 4;
    } else if (screenWidth < 400) {
      count = 2;
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
              height: 40,
              padding: EdgeInsets.only(left: 8, right: 8),
              child: Text(
                widget.wenkuNovelList[index].titleZh,
                style: TextStyle(fontSize: 12),
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
      padding: EdgeInsets.all(5), // 设置四周内边距
      sliver: SliverGrid.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: count,
          // mainAxisSpacing: 5,
          // crossAxisSpacing: 5,
          childAspectRatio: 0.6,
        ),
        itemBuilder: (BuildContext context, int index) {
          if (widget.wenkuNovelList.isEmpty) {
            return Skeletonizer(
              enabled: true,
              child: _placeholder(), // 提供一个空壳模型
            );
          }
          return getGridItems(index);
        },
        itemCount: widget.wenkuNovelList.isEmpty
            ? 24
            : widget.wenkuNovelList.length,
      ),
    );
  }
}

Widget _placeholder() {
  return Column(
    children: [
      Expanded(
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Image.network(
            fit: BoxFit.cover,
            width: double.infinity, // 宽度充满
            "",
            errorBuilder: (context, error, stackTrace) {
              return SizedBox(
                width: double.infinity,
                child: Text('', textAlign: TextAlign.center),
              );
            },
          ),
        ),
      ),
      Container(
        height: 40,
        padding: EdgeInsets.only(left: 8, right: 8),
        child: Text(
          "-------------",
          style: TextStyle(fontSize: 12),
          // 设置最大显示行
          maxLines: 2,
          // 设置文本溢出, 时效果
          overflow: TextOverflow.ellipsis, // 显示 ...
        ),
      ),
    ],
  );
}
