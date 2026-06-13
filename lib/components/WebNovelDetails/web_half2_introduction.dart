import 'package:flutter/material.dart';

class WebHalf2Introduction extends StatelessWidget {
  final List<String> introductions;

  const WebHalf2Introduction({super.key, required this.introductions});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Text(introductions[1]),
                const SizedBox(height: 20),
                Text(introductions[0]),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(child: const SizedBox(height: 50)),
      ],
    );
  }
}
