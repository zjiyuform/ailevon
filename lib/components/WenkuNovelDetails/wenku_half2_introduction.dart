import 'package:flutter/material.dart';

class WenkuHalf2Introduction extends StatelessWidget {
  final String introduction;
  final ScrollController? scrollController;

  const WenkuHalf2Introduction({
    super.key,
    required this.introduction,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [const SizedBox(height: 10), Text(introduction)],
            ),
          ),
        ),
        SliverToBoxAdapter(child: const SizedBox(height: 50)),
      ],
    );
  }
}
