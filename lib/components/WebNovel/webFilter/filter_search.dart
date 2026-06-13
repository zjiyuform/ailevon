import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ailevon/stores/user_controller.dart';

class FilterSearch extends StatefulWidget {
  // 定义回调函数：当搜寻筛选变化时，向外传递 Map<String, dynamic>
  final Function(Map<String, dynamic>)? onSearchFilterChanged;
  final String initialQuery; // 接收初始值
  const FilterSearch({
    super.key,
    this.onSearchFilterChanged,
    this.initialQuery = "",
  });

  @override
  State<FilterSearch> createState() => _FilterSearchState();
}

class _FilterSearchState extends State<FilterSearch> {
  // 设置 控制器, 用于绑定为 TextField 的 controller 属性
  final TextEditingController _searchController =
      TextEditingController(); // 搜索控制器

  final UserController _userController = Get.find();

  // 设计一个符合返回webAPI请求的Map
  late Map<String, dynamic> _webParams1;

  @override
  void initState() {
    super.initState();
    // 初始化默认
    _webParams1 = {"query": widget.initialQuery};
    // 初始化 TextController
    _searchController.text = widget.initialQuery;
    // 判断是否登录, 跳转登录时,使level选项变为"0"
    if ((_userController.user.value.username.isNotEmpty) &&
        (DateTime.now().millisecondsSinceEpoch ~/ 1000 -
                _userController.user.value.createdAt) >
            2592000) {
      _webParams1["level"] = "0";
    }
    // 初始化时触发一次回调，传递默认值
    if (widget.onSearchFilterChanged != null) {
      // 更稳定的初始化回调，避免微任务导致的布局异常
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onSearchFilterChanged?.call(_webParams1);
      });
    }
  }

  @override
  void dispose() {
    // 释放输入控制器
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildTextField() {
    // 在 flutter 获取屏幕宽高度的方法
    final double screenWidth = MediaQuery.of(context).size.width; // 屏幕宽度
    return Row(
      children: [
        SizedBox(
          width: 40,
          child: Text(
            "搜索",
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            maxLines: 1,
            softWrap: false,
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          // color: Colors.blue,
          width: screenWidth * 0.5,
          height: 40,
          child: TextField(
            controller: _searchController,
            scrollPadding: EdgeInsets.zero,
            scrollPhysics: BouncingScrollPhysics(),
            style: TextStyle(fontSize: 16, height: 1.0),
            onSubmitted: (value) {
              _webParams1["query"] = value;
              // 按下enter时，调用回调向外传递参数
              if (widget.onSearchFilterChanged != null) {
                widget.onSearchFilterChanged!(_webParams1);
              }
            },

            decoration: InputDecoration(
              hintText: '搜索...',
              hintStyle: TextStyle(fontSize: 14),
              prefixIcon: Icon(Icons.search, size: 20),
              isDense: true, // 让输入框更紧凑
              // 设置边框
              border: OutlineInputBorder(
                // borderSide: BorderSide.none, // 不显示边框
                borderSide: BorderSide(
                  width: 0.5,
                ), // 未聚焦且未启用时的边框（通常与enabledBorder相同）
                borderRadius: BorderRadius.circular(20),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(width: 0.5), // 启用状态下的边框
                borderRadius: BorderRadius.circular(20),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(width: 0.5), // 聚焦状态下的边框，宽度与上面一致
                borderRadius: BorderRadius.circular(20),
              ),

              suffixIcon: IconButton(
                icon: Icon(Icons.clear, size: 16),
                onPressed: () => {_searchController.clear()},
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        GestureDetector(
          onTap: () {
            _webParams1["query"] = _searchController.text;

            // 点击图标时，调用回调向外传递参数
            if (widget.onSearchFilterChanged != null) {
              widget.onSearchFilterChanged!(_webParams1);
            }
          },
          child: Container(alignment: Alignment.center, child: Icon(Icons.web)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      child: _buildTextField(),
    );
  }
}
