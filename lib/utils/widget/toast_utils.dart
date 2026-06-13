// 吐司提示（Toast）是一种轻量级的反馈或提示方式，通常会在屏幕中显示一段时间后自动消失
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

// // 底部
// class ToastUtils1 {
//   static void showToast(BuildContext context, String? msg) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           msg ?? "刷新成功~",
//           textAlign: TextAlign.center,
//           style: TextStyle(color: Colors.green, fontSize: 25),
//         ),
//         behavior: SnackBarBehavior.floating, // 设置位置行为
//         duration: Duration(seconds: 1), // 设置持续时间
//         backgroundColor: Colors.transparent, // 设置透明背景
//         elevation: 0, // 去除阴影
//       ),
//     );
//   }
// }

class ToastUtils2 {
  static void showToast(String? msg) {
    Fluttertoast.showToast(
      msg: msg ?? "",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      webPosition: "center",
      webShowClose: true,
    );
  }

  static void showToastBottom(String? msg) {
    Fluttertoast.showToast(
      msg: msg ?? "",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      webPosition: "center",
      webShowClose: true,
    );
  }
}
