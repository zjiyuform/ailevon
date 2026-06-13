import 'package:flutter/material.dart';

class LoadingDialog {
  // 显示
  static void show(BuildContext context, {String message = "加载中..."}) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Center(
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                // 设置主轴大小
                mainAxisSize: MainAxisSize.min, //设置最小
                children: [
                  // 加载圈组件
                  CircularProgressIndicator(color: Colors.green),
                  const SizedBox(height: 10),
                  Text(message),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 关闭
  static void hide(BuildContext context) {
    Navigator.pop(context);
  }
}
