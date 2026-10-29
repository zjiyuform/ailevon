class Comment {
  String id;
  Map<String, dynamic> user;
  String content;
  bool hidden;
  int createAt;
  int numReplies;
  List<Comment> replies;
  Comment({
    required this.id,
    required this.user,
    required this.content,
    required this.hidden,
    required this.createAt,
    required this.numReplies,
    this.replies = const [],
  });
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json["id"] ?? "",
      user: json["user"] ?? {},
      content: json["content"] ?? "",
      hidden: json["hidden"] ?? false,
      createAt: json["createAt"] ?? -1,
      numReplies: json["numReplies"] ?? -1,
      replies:
          (json["replies"] as List<dynamic>?)
              ?.map((e) => Comment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
