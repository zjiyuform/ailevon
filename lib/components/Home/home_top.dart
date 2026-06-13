import 'package:flutter/material.dart';
import 'package:ailevon/components/PublicWidgt/avatar.dart';
import 'package:ailevon/components/PublicWidgt/search_textfield.dart';
import 'package:ailevon/utils/Function/url_reg.dart';

class HomeSearch extends StatefulWidget {
  const HomeSearch({super.key});

  @override
  State<HomeSearch> createState() => _HomeSearchState();
}

class _HomeSearchState extends State<HomeSearch> {
  String _searchValue = "";

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true, // 关键：滚动时保持吸顶
      title: PubSearch(upSearchValue: (String value) => _searchValue = value),

      actions: [
        IconButton(
          onPressed: () {
            if (parseNovelUrl(_searchValue) != null) {
              var urlRecord = parseNovelUrl(_searchValue);
              final providerId = urlRecord!.platform;
              final novelId = urlRecord.id;
              final routeName =
                  "/webnoveldetails?provider=${Uri.encodeComponent(providerId)}&novelId=${Uri.encodeComponent(novelId)}";
              Navigator.pushNamed(context, routeName);
            } else {
              Navigator.pushNamed(
                context,
                "/websearch",
                arguments: {"search": _searchValue},
              );
            }
          },
          icon: const Icon(Icons.web),
        ),

        IconButton(
          onPressed: () {
            Navigator.pushNamed(
              context,
              "/wenkusearch",
              arguments: {"search": _searchValue},
            );
          },
          icon: const Icon(Icons.book),
        ),
        const SizedBox(width: 10),
      ],

      leading: Builder(
        // Builder 用来获取正确的 Scaffold 上下文，否则无法打开抽屉
        builder: (context) => IconButton(
          icon: PubAvatar(),
          // 点击头像打开抽屉，和原菜单按钮功能一致
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
    );
  }
}
