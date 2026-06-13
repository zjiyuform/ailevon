import 'package:flutter/material.dart';
import 'dart:async';

class WebStarSingle extends StatefulWidget {
  final Map<String, List<String>> filterMap;
  final int debounceMilliseconds; // 可配置防抖延迟时间
  // 子传父设置
  // 定义回调函数：当单选筛选变化时，向外传递 Map<String, dynamic>
  final Function(Map<String, dynamic>)? onSingleFilterChanged;
  const WebStarSingle({
    super.key,
    required this.filterMap,
    this.onSingleFilterChanged,
    this.debounceMilliseconds = 300, // 默认 300ms
  });

  @override
  State<WebStarSingle> createState() => _WebStarSingleState();
}

class _WebStarSingleState extends State<WebStarSingle> {
  late Map<String, String?> _selectedMap;
  // 设计一个符合返回webAPI请求的Map
  late Map<String, dynamic> _webParams3;
  Timer? _debounceTimer; // 防抖定时器

  @override
  void initState() {
    super.initState();
    // 初始化默认选中第一个
    _selectedMap = {
      for (var entry in widget.filterMap.entries)
        entry.key: (entry.value.isNotEmpty) ? entry.value.first : null,
    };
    // print(_selectedMap);
    _webParams3 = {"type": 0, "level": 0, "translate": 0, "sort": "update"};
    // print(_webParams3);
    // 回调新增, 初始化时触发一次回调，传递默认值
    if (widget.onSingleFilterChanged != null) {
      // 更稳定的初始化回调，避免微任务导致的布局异常
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onSingleFilterChanged?.call(_webParams3);
      });
    }
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
                      if (isSelected) {
                        return;
                      }
                      _selectedMap[category] = tag;
                      var wp3k = _webParams3.keys.toList();
                      // 判断是点击的category否为"排序"
                      if (category != "排序") {
                        _webParams3[wp3k[_selectedMap.keys.toList().indexOf(
                          category,
                        )]] = tags.indexOf(
                          tag,
                        );
                      } else {
                        _webParams3[wp3k[_selectedMap.keys.toList().indexOf(
                          category,
                        )]] = tags.indexOf(tag) == 0
                            ? "update"
                            : "create";
                      }

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
