/// 格式化时间差，返回类似 "刚刚"、"5分钟前"、"2小时前" 等
String formatTimeAgo(int secondsSinceEpoch) {
  final now = DateTime.now();
  final target = DateTime.fromMillisecondsSinceEpoch(secondsSinceEpoch);

  // 只比较日期部分（忽略时分秒）
  final nowDate = DateTime(now.year, now.month, now.day);
  final targetDate = DateTime(target.year, target.month, target.day);
  final diffDays = nowDate.difference(targetDate).inDays;

  if (diffDays >= 365) {
    final years = (diffDays / 365).floor();
    return '$years年前';
  } else if (diffDays >= 30) {
    final months = (diffDays / 30).floor();
    return '$months个月前';
  } else if (diffDays >= 1) {
    return '$diffDays天前';
  }

  // 不足一天时，继续用精确时间差来显示“小时前”“分钟前”等
  final diff = now.difference(target);
  if (diff.inHours >= 1) {
    return '${diff.inHours}小时前';
  } else if (diff.inMinutes >= 1) {
    return '${diff.inMinutes}分钟前';
  } else if (diff.inSeconds >= 10) {
    return '${diff.inSeconds}秒前';
  } else {
    return '刚刚';
  }
}

/// y-m-d
String formartDate(int secondsSinceEpoch) {
  DateTime utcDate = DateTime.fromMillisecondsSinceEpoch(
    secondsSinceEpoch * 1000,
    isUtc: true,
  );
  DateTime japanDate = utcDate.add(Duration(hours: 9));
  String ymd =
      "${japanDate.year}-${japanDate.month.toString().padLeft(2, '0')}-${japanDate.day.toString().padLeft(2, '0')}";
  return ymd;
}

/// y-m-d h-m
String formartDateHM(int secondsSinceEpoch) {
  DateTime utcDate = DateTime.fromMillisecondsSinceEpoch(
    secondsSinceEpoch * 1000,
    isUtc: true,
  );
  DateTime japanDate = utcDate.add(const Duration(hours: 9));
  String ymd =
      "${japanDate.year}-${japanDate.month.toString().padLeft(2, '0')}-${japanDate.day.toString().padLeft(2, '0')}";
  String hm =
      "${japanDate.hour.toString().padLeft(2, '0')}:${japanDate.minute.toString().padLeft(2, '0')}";
  return "$ymd $hm";
}
