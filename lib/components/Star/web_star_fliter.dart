import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ailevon/components/Star/web_star_single.dart';
import 'package:ailevon/components/WebNovel/webFilter/filter_search.dart';
import 'package:ailevon/components/WebNovel/webFilter/filter_multiple.dart';
import 'package:ailevon/stores/user_controller.dart';

class WebStarFliter extends StatefulWidget {
  // 定义总回调：将单选+多选参数合并后，传递给父组件
  final Function(Map<String, dynamic>)? onFilterChanged;
  final String initialQuery; // 接收初始值
  const WebStarFliter({
    super.key,
    this.onFilterChanged, // 构造函数接收回调
    this.initialQuery = "",
  });

  @override
  State<WebStarFliter> createState() => _WebStarFliterState();
}

class _WebStarFliterState extends State<WebStarFliter> {
  //  用于合并单选+多选参数, 传递给父组件
  final Map<String, dynamic> _totalFilterParams = {};

  // 可多选的tag
  final Map<String, List<String>> _webFilterMultipleMap = {
    "来源": ["Kakuyomu", "Syosetu", "Novelup", "Hameln", "Pixiv", "Alphapolis"],
  };
  // 单选的tag
  final Map<String, List<String>> _webFilterSingleMap = {
    "类型": ["全部", "连载中", "已完结", "短篇"],
    "分级": ["全部", "一般向", "R18"],
    "翻译": ["全部", "GPT", "sakura"],
    "排序": ["更新时间", "收藏时间"],
  };
  final UserController _userController = Get.find();
  // 回调新增, 合并参数并转发给父组件
  void _mergeAndSendParams() {
    if (widget.onFilterChanged != null) {
      widget.onFilterChanged!(_totalFilterParams);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 30),
        child: Column(
          children: [
            //
            FilterSearch(
              onSearchFilterChanged: (searchParam) {
                _totalFilterParams.addAll(searchParam);
                _mergeAndSendParams();
              },
            ),
            // 接收多选组件的回调
            FliterMultiple(
              filterMap: _webFilterMultipleMap,
              onMultipleFilterChanged: (multipleParams) {
                _totalFilterParams.addAll(multipleParams);
                _mergeAndSendParams();
              },
            ),
            // 接收单选组件的回调
            WebStarSingle(
              filterMap:
                  (DateTime.now().millisecondsSinceEpoch ~/ 1000 -
                          _userController.user.value.createdAt) >
                      2592000
                  ? _webFilterSingleMap
                  : {
                      "类型": ["全部", "连载中", "已完结", "短篇"],
                      "翻译": ["全部", "GPT", "sakura"],
                      "排序": ["更新时间", "收藏时间"],
                    },
              onSingleFilterChanged: (singleParams) {
                _totalFilterParams.addAll(singleParams);
                _mergeAndSendParams();
              },
            ),
          ],
        ),
      ),
    );
  }
}
