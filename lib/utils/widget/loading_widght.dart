import 'package:flutter/material.dart';

class LoadingWidght {
  // sliver类等待组件
  static Widget showSliver() {
    return const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
          ),
        ),
      ),
    );
  }

  // 普通等待组件
  static Widget showCommon() {
    return const SizedBox(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
          ),
        ),
      ),
    );
  }
}
