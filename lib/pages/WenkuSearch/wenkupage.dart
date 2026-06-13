import 'package:flutter/material.dart';
import 'package:ailevon/pages/WenkuSearch/wenkusearchbody.dart';

class WenkuSearchPage extends StatefulWidget {
  const WenkuSearchPage({super.key});

  @override
  State<WenkuSearchPage> createState() => _WenkuSearchPageState();
}

class _WenkuSearchPageState extends State<WenkuSearchPage> {
  // 设置滚动控制器
  final ScrollController _controller = ScrollController();

  // 定义一个变量来存初始搜索词
  String _initialQuery = "";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    final newQuery = (args is Map && args.isNotEmpty)
        ? args.values.first.toString()
        : "";
    if (_initialQuery != newQuery) {
      _initialQuery = newQuery;
      // print(_initialQuery);
    }
  }

  void _scrollListToTop(ScrollController controller) {
    if (controller.position.pixels < 10000) {
      controller.animateTo(
        0,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    } else {
      controller.jumpTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("文库小说"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.keyboard_double_arrow_up),
            onPressed: () {
              // 点击处理
              _scrollListToTop(_controller);
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: WenkuSearchBody(
        controller: _controller,
        initialQuery: _initialQuery,
      ),
    );
  }
}
