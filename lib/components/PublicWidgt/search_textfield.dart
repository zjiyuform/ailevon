import 'package:flutter/material.dart';
import 'package:ailevon/utils/Function/url_reg.dart';

class PubSearch extends StatefulWidget {
  final Function? upSearchValue;
  const PubSearch({super.key, this.upSearchValue});

  @override
  State<PubSearch> createState() => _PubSearchState();
}

class _PubSearchState extends State<PubSearch> {
  // 设置 控制器, 用于绑定为 TextField 的 controller 属性
  final TextEditingController _searchController =
      TextEditingController(); // 搜索控制器

  Widget _buildTextField() {
    return TextField(
      controller: _searchController,
      scrollPhysics: BouncingScrollPhysics(),
      onChanged: (value) {
        widget.upSearchValue!(value);
      },
      onSubmitted: (value) {
        if (value.isNotEmpty) {
          if (parseNovelUrl(value) != null) {
            var urlRecord = parseNovelUrl(value);
            final providerId = urlRecord!.platform;
            final novelId = urlRecord.id;
            final routeName =
                "/webnoveldetails?provider=${Uri.encodeComponent(providerId)}&novelId=${Uri.encodeComponent(novelId)}";
            Navigator.pushNamed(context, routeName);
          } else {
            Navigator.pushNamed(
              context,
              "/websearch",
              arguments: {"search": value},
            );
          }
        }
      },
      style: TextStyle(fontSize: 16, height: 1.15),
      decoration: InputDecoration(
        hintText: '搜索...',
        hintStyle: TextStyle(fontSize: 14),
        prefixIcon: Icon(Icons.search, size: 20),
        contentPadding: EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 12,
        ), // 减小内边距
        isDense: true, // 让输入框更紧凑
        suffixIcon: IconButton(
          icon: Icon(Icons.clear, size: 16),
          onPressed: () {
            _searchController.clear();
            widget.upSearchValue!("");
          },
        ),
        // OutlineInputBorder组件 设置文本框边框
        border: OutlineInputBorder(
          borderSide: BorderSide(width: 0.5), // 未聚焦且未启用时的边框（通常与enabledBorder相同）
          borderRadius: BorderRadius.circular(40),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(width: 0.5), // 启用状态下的边框
          borderRadius: BorderRadius.circular(40),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(width: 0.5), // 聚焦状态下的边框，宽度与上面一致
          borderRadius: BorderRadius.circular(40),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(child: _buildTextField());
  }
}
