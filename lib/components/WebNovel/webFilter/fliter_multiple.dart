import 'dart:async';

import 'package:flutter/material.dart';

class FliterMultiple extends StatefulWidget {
  final Map<String, List<String>> filterMap;
  // 定义回调函数：当多选筛选变化时，向外传递 Map<String, dynamic>
  final Function(Map<String, dynamic>)? onMultipleFilterChanged;
  final int debounceMilliseconds; // 可配置防抖延迟时间

  const FliterMultiple({
    super.key,
    required this.filterMap,
    this.onMultipleFilterChanged, // 构造函数接收回调
    this.debounceMilliseconds = 300, // 默认 300ms
  });

  @override
  State<FliterMultiple> createState() => _FliterMultipleState();
}

class _FliterMultipleState extends State<FliterMultiple> {
  // 从 String? 改成 List<String> 支持多选
  late Map<String, List<String>> _selectedMap;
  // 设计一个符合返回webAPI请求的Map
  late Map<String, dynamic> _webParams2 = {};
  Timer? _debounceTimer; // 防抖定时器

  @override
  void initState() {
    super.initState();
    // 默认选中所有标签
    _selectedMap = {
      for (var entry in widget.filterMap.entries)
        entry.key: entry.value.isNotEmpty ? List.from(entry.value) : [],
    };
    _webParams2 = {
      "provider": "kakuyomu,syosetu,novelup,hameln,pixiv,alphapolis",
    };
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
        if (widget.onMultipleFilterChanged != null) {
          widget.onMultipleFilterChanged!(_webParams2);
        }
      },
    );
  }

  // 自定义文本标签
  Widget _buildCustomTag(String tag, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        alignment: Alignment.center,
        child: Text(
          tag,
          style: TextStyle(
            fontSize: 12,
            height: 1.15,
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
      final selectedTags = _selectedMap[category] ?? [];

      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
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
          Expanded(
            child: SizedBox(
              height: 30,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: tags.length,
                itemBuilder: (context, index) {
                  final tag = tags[index];
                  final isSelected = selectedTags.contains(tag); // 判断是否选中

                  return _buildCustomTag(tag, isSelected, () {
                    setState(() {
                      //  多选核心逻辑, 点击切换选中/取消
                      if (isSelected) {
                        selectedTags.remove(tag);
                        _webParams2["provider"] = selectedTags
                            .join(",")
                            .toLowerCase();
                        // print(tags);
                        // print(tag);
                        // print(tags.indexOf(tag));
                        // print(_webParams2);
                      } else {
                        selectedTags.add(tag);
                        _webParams2["provider"] = selectedTags
                            .join(",")
                            .toLowerCase();
                        // print(_webParams2);
                      }

                      // 防抖调用外部回调，不会阻塞 UI 更新
                      _debounce();
                      // // 筛选变化时，调用回调向外传递参数
                      // if (widget.onMultipleFilterChanged != null) {
                      //   widget.onMultipleFilterChanged!(_webParams2);
                      // }
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
