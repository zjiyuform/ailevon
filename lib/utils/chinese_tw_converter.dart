// import 'dart:async';
// import 'package:flutter/foundation.dart';
import 'chinese_tw_maps.dart'; // 预编译的常量映射

// ============================================================
// 短语 Trie 树节点
// ============================================================
class _PhraseTrieNode {
  final Map<String, _PhraseTrieNode> children = {};
  String? output; // 匹配到的繁体短语结果
}

// ============================================================
// 短语 Trie 树（全局单例，启动时构建一次）
// ============================================================
_PhraseTrieNode _buildPhraseTrie() {
  final root = _PhraseTrieNode();
  s2twPhraseMap.forEach((key, value) {
    var node = root;
    for (int i = 0; i < key.length; i++) {
      final char = key[i];
      node = node.children.putIfAbsent(char, () => _PhraseTrieNode());
    }
    node.output = value;
  });
  return root;
}

final _phraseTrie = _buildPhraseTrie();

// ============================================================
// 核心转换逻辑（同步，可放入 Isolate）
// ============================================================
String _convertCore(String text) {
  if (text.isEmpty) return text;

  // 1. 使用 Trie 树进行短语最大正向匹配替换
  final phraseBuffer = StringBuffer();
  int i = 0;
  while (i < text.length) {
    var node = _phraseTrie;
    int matchedLen = 0;
    String? matchedValue;

    // 尝试匹配最长短语
    for (int j = i; j < text.length; j++) {
      final char = text[j];
      final child = node.children[char];
      if (child == null) break;
      node = child;
      if (node.output != null) {
        matchedLen = j - i + 1;
        matchedValue = node.output;
      }
    }

    if (matchedValue != null) {
      phraseBuffer.write(matchedValue);
      i += matchedLen;
    } else {
      phraseBuffer.write(text[i]);
      i++;
    }
  }

  // 2. 单字映射替换
  final result = phraseBuffer.toString();
  final charBuffer = StringBuffer();
  for (int i = 0; i < result.length; i++) {
    final char = result[i];
    charBuffer.write(s2twCharMap[char] ?? char);
  }

  return charBuffer.toString();
}

// ============================================================
// 公开转换工具类
// ============================================================
class ChineseTWConverter {
  // 同步转换（适用于短文本，如标题、评论）
  static String convertSync(String text) {
    return _convertCore(text);
  }

  // 异步转换（适用于长文本，如小说章节）
  // 自动判断：长度 < 500 同步执行，否则放入 Isolate
  // static Future<String> convert(String text) async {
  //   if (text.isEmpty) return text;
  //   if (text.length < 500) {
  //     return _convertCore(text); // 短文本直接同步
  //   }
  //   // 长文本使用 compute 移入后台 Isolate
  //   return compute(_convertCore, text);
  // }
}
