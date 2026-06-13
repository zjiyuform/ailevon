import 'package:flutter/material.dart';

class HomeTopimg extends StatefulWidget {
  const HomeTopimg({super.key});

  @override
  State<HomeTopimg> createState() => _HomeTopimgState();
}

class _HomeTopimgState extends State<HomeTopimg> {
  // 定义一个背景图片
  Widget _getBannerBg() {
    // 在 flutter 获取屏幕宽高度的方法
    final double screenWidth = MediaQuery.of(context).size.width; // 屏幕宽度
    return Image.asset(
      "lib/assets/banner.v1.webp",
      height: 120,
      width: screenWidth,
      fit: BoxFit.cover,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(child: _getBannerBg());
  }
}
