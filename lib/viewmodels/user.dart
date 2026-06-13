class UserInfo {
  String username;
  String role;
  int issuedAt;
  int expiresAt;
  int createdAt; // crat
  String? token;

  UserInfo({
    required this.username,
    required this.role,
    required this.issuedAt,
    required this.expiresAt,
    required this.createdAt,
    this.token,
  });

  factory UserInfo.fromJSON(Map<String, dynamic> payload) {
    return UserInfo(
      username: payload['sub'] ?? "",
      role: payload['role'] ?? "",
      issuedAt: payload['iat'] ?? -1,
      expiresAt: payload['exp'] ?? -1,
      createdAt: payload['crat'] ?? -1,
      token: payload['token'] ?? "",
    );
  }
}
