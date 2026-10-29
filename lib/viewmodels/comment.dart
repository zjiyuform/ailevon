class Comment {
  final int id;
  final String subjectKey;
  final int? rootId;
  final String content;

  // 作者信息（原 user Map 被拍平）
  final int authorId;
  final String authorUsername;
  final bool authorBlocked;

  final int status;
  final int createdAt; // 毫秒时间戳，-1 表示无效
  final int updatedAt; // 毫秒时间戳，-1 表示无效

  final int replyCount;
  final List<Comment> replies; // 直接从 replies.items 解析

  /// 纯前端状态，不从接口读
  bool hidden;

  Comment({
    required this.id,
    required this.subjectKey,
    required this.rootId,
    required this.content,
    required this.authorId,
    required this.authorUsername,
    required this.authorBlocked,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.replyCount,
    this.replies = const [],
    this.hidden = false,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: (json['id'] as num?)?.toInt() ?? 0,
      subjectKey: json['subjectKey'] as String? ?? '',
      rootId: (json['rootId'] as num?)?.toInt(),
      content: json['content'] as String? ?? '',
      authorId: (json['authorId'] as num?)?.toInt() ?? 0,
      authorUsername: json['authorUsername'] as String? ?? '',
      authorBlocked: json['authorBlocked'] as bool? ?? false,
      status: (json['status'] as num?)?.toInt() ?? 0,
      createdAt: _parseTimestamp(json['createdAt']),
      updatedAt: _parseTimestamp(json['updatedAt']),
      replyCount: (json['replyCount'] as num?)?.toInt() ?? 0,
      replies: _parseReplies(json['replies']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subjectKey': subjectKey,
      'rootId': rootId,
      'content': content,
      'authorId': authorId,
      'authorUsername': authorUsername,
      'authorBlocked': authorBlocked,
      'status': status,
      'createdAt': createdAt, // int，直接输出
      'updatedAt': updatedAt, // int，直接输出
      'replyCount': replyCount,
      'replies': {'items': replies.map((e) => e.toJson()).toList()},
    };
  }

  /// 统一返回毫秒时间戳，失败返回 -1
  /// 兼容：ISO8601 字符串 / 已经是 int 的时间戳 / DateTime 对象
  static int _parseTimestamp(dynamic v) {
    // print(v);
    if (v == null) return -1;
    if (v is int) return v;
    if (v is DateTime) return v.millisecondsSinceEpoch;
    if (v is String && v.isNotEmpty) {
      // print(DateTime.tryParse(v)?.millisecondsSinceEpoch);
      return DateTime.tryParse(v)?.millisecondsSinceEpoch ?? -1;
    }
    return -1;
  }

  /// replies 是 { total, items } 对象，只取 items；不存在则空列表
  static List<Comment> _parseReplies(dynamic raw) {
    if (raw is! Map<String, dynamic>) return const [];
    final items = raw['items'];
    if (items is! List) return const [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(Comment.fromJson)
        .toList();
  }

  // ---------- 兼容旧字段 ----------

  Map<String, dynamic> get user => {
    'id': authorId,
    'username': authorUsername,
    'blocked': authorBlocked,
  };

  int get numReplies => replyCount;

  int get createAt => createdAt;
}
