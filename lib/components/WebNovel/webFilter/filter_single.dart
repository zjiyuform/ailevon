import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';

import 'package:ailevon/stores/user_controller.dart';

class FilterSingle extends StatefulWidget {
  final Map<String, List<String>> filterMap;
  final int debounceMilliseconds; // 可配置防抖延迟时间
  // 子传父设置
  // 定义回调函数：当单选筛选变化时，向外传递 Map<String, dynamic>
  final Function(Map<String, dynamic>)? onSingleFilterChanged;
  const FilterSingle({
    super.key,
    required this.filterMap,
    this.onSingleFilterChanged,
    this.debounceMilliseconds = 300, // 默认 300ms
  });

  @override
  State<FilterSingle> createState() => _FilterSingleState();
}

class _FilterSingleState extends State<FilterSingle> {
  late Map<String, String?> _selectedMap;
  // 设计一个符合返回webAPI请求的Map
  late Map<String, dynamic> _webParams3;
  Timer? _debounceTimer; // 防抖定时器

  // 主页初始化时Get.put(), 在此处Get.find()
  final UserController _userController = Get.find();

  @override
  void initState() {
    super.initState();
    // 初始化默认选中第一个
    _selectedMap = {
      for (var entry in widget.filterMap.entries)
        entry.key: (entry.value.isNotEmpty) ? entry.value.first : null,
    };
    // print(_selectedMap);
    _userController.user.value.username.isNotEmpty
        ? _webParams3 = {"type": 0, "level": 0, "translate": 0, "sort": 0}
        : _webParams3 = {"type": 0, "translate": 0, "sort": 0};
    // print(_webParams3);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel(); // 组件销毁时取消定时器
    super.dispose();
  }

  /// 防抖调用：取消之前的 Timer，重新开始计时，延迟后执行回调
  void _debounce() {
    if (_debounceTimer != null) {
      _debounceTimer!.cancel();
    }
    _debounceTimer = Timer(
      Duration(milliseconds: widget.debounceMilliseconds),
      () {
        if (widget.onSingleFilterChanged != null) {
          widget.onSingleFilterChanged!(_webParams3);
        }
      },
    );
  }

  // 构建自定义标签的核心方法
  Widget _buildCustomTag(String tag, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        child: Text(
          tag,
          style: TextStyle(
            fontSize: 12,
            height: 1.15, // 适配中文行高
            color: isSelected ? Colors.green : null,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFilterRows() {
    return widget.filterMap.entries.map((entry) {
      final category = entry.key;
      final tags = entry.value;
      final selectedTag = _selectedMap[category];

      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 左侧分类
          SizedBox(
            width: 40,
            child: Text(
              category,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              maxLines: 1,
              softWrap: false,
            ),
          ),
          const SizedBox(width: 8),
          // 右侧横向滚动的标签列表
          Expanded(
            child: SizedBox(
              height: 30, // 仅限制行高，不限制内部标签
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: tags.length,
                itemBuilder: (context, index) {
                  final tag = tags[index];
                  final isSelected = selectedTag == tag; // 获取布尔值

                  return _buildCustomTag(tag, isSelected, () {
                    setState(() {
                      // 点击逻辑：如果是已选中则取消，否则选中
                      // _selectedMap[category] = isSelected ? null : tag;
                      // 点击逻辑：如果是已选中则操作，否则选中
                      // if (isSelected) {
                      //   return;
                      // }
                      // 因为"分页数据漂移", 重复点击相当于刷新页面
                      _selectedMap[category] = tag;
                      var wp3k = _webParams3.keys.toList();
                      _webParams3[wp3k[_selectedMap.keys.toList().indexOf(
                        category,
                      )]] = tags.indexOf(
                        tag,
                      );

                      // 防抖调用外部回调，不会阻塞 UI 更新

                      // // 筛选变化时，调用回调向外传递参数
                      // if (widget.onSingleFilterChanged != null) {
                      //   widget.onSingleFilterChanged!(_webParams3);
                      // }
                      // print(_selectedMap);
                      // print(_selectedMap[category]);
                      // print(category);
                      // print(tags);
                      // print(tag);
                      // print(tags.indexOf(tag));
                      // print(_webParams3);
                      _debounce();
                    });
                  });
                },
                separatorBuilder: (context, index) => const SizedBox(width: 20),
              ),
            ),
          ),
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: _buildFilterRows());
  }
}
