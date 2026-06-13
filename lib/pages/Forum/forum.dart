import 'package:flutter/material.dart';

class ForumView extends StatefulWidget {
  // 接收父组件传递的 ScrollController, 用于实现点击底部tap时,触发滚动事件
  final ScrollController? controller;
  const ForumView({super.key, this.controller});

  @override
  State<ForumView> createState() => _ForumViewState();
}

class _ForumViewState extends State<ForumView> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: widget.controller,
      slivers: [
        SliverList.builder(
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsetsGeometry.symmetric(horizontal: 30),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                // color: Colors.blue,
                decoration: BoxDecoration(
                  // color: Colors.white,
                  border: Border(bottom: BorderSide(width: 0.5)),
                ),
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Text("讨论", style: TextStyle(color: Colors.green))],
                ),
              ),
            );
          },
          itemCount: 30,
        ),
      ],
    );
  }
}
