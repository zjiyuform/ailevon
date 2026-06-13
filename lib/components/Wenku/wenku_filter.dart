import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ailevon/components/Wenku/wenkuFilter/filter_search.dart';
import 'package:ailevon/components/Wenku/wenkuFilter/filter_single.dart';

import 'package:ailevon/stores/user_controller.dart';

class WenkuFilter extends StatefulWidget {
  // 定义总回调：将单选+多选参数合并后，传递给父组件
  final Function(Map<String, dynamic>)? onFilterChanged;
  final String initialQuery; // 接收初始值

  const WenkuFilter({
    super.key,
    this.onFilterChanged, // 构造函数接收回调
    this.initialQuery = "",
  });

  @override
  State<WenkuFilter> createState() => _WenkuFilterState();
}

class _WenkuFilterState extends State<WenkuFilter> {
  //  用于合并参数, 传递给父组件
  final Map<String, dynamic> _totalFilterParams = {};

  // 单选的tag
  final Map<String, List<String>> _wenkuFilterSingleMap = {
    "分级": ["全部小说", "轻小说", "轻文学", "文学", "非小说"],
  };

  // 主页初始化时Get.put(), 在此处Get.find()
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
              initialQuery: widget.initialQuery,
              onSearchFilterChanged: (searchParam) {
                _totalFilterParams.addAll(searchParam);
                _mergeAndSendParams();
              },
            ),
            // 接收单选组件的回调
            FilterSingle(
              filterMap:
                  (_userController.user.value.username.isNotEmpty) &&
                      (DateTime.now().millisecondsSinceEpoch ~/ 1000 -
                              _userController.user.value.createdAt) >
                          2592000
                  ? {
                      "分级": [
                        "全部小说",
                        "轻小说",
                        "轻文学",
                        "文学",
                        "非小说",
                        "R18男性向",
                        "R18女性向",
                      ],
                    }
                  : _wenkuFilterSingleMap,
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
