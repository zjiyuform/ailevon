import 'dart:io';

void main() {
  // 1. 读取 STCharacters.txt
  final charLines = File('/opencc/STCharacters.txt').readAsLinesSync();
  final charMap = <String, String>{};
  for (var line in charLines) {
    if (line.isEmpty || line.startsWith('#')) continue;
    final parts = line.split('\t');
    if (parts.length >= 2) {
      charMap[parts[0]] = parts[1].split(' ')[0];
    }
  }

  // 2. 读取 STPhrases.txt
  final phraseLines = File('/opencc/STPhrases.txt').readAsLinesSync();
  final phraseMap = <String, String>{};
  for (var line in phraseLines) {
    if (line.isEmpty || line.startsWith('#')) continue;
    final parts = line.split('\t');
    if (parts.length >= 2) {
      phraseMap[parts[0]] = parts[1].split(' ')[0];
    }
  }

  // 3. 生成 Dart 文件
  final output = File('lib/utils/chinese_tw_maps.dart');
  output.writeAsStringSync('''
/// 简体 → 台湾繁体单字映射表（自动生成）
const Map<String, String> s2twCharMap = ${_mapToDart(charMap)};

/// 简体词汇 → 台湾繁体短语映射表（自动生成）
const Map<String, String> s2twPhraseMap = ${_mapToDart(phraseMap)};
''');

  // ignore: avoid_print
  print(' 生成完成: lib/utils/chinese_tw_maps.dart');
}

String _mapToDart(Map<String, String> map) {
  final buffer = StringBuffer('{');
  map.forEach((k, v) {
    buffer.write("'$k':'$v',");
  });
  buffer.write('}');
  return buffer.toString();
}
