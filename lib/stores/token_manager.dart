import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenManager {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // 缓存（与旧版完全一致，初始为空字符串）
  String _token = "";

  // 可选：单独存储 refresh token（不影响旧代码）
  String? _refreshToken;

  /// 初始化：从安全存储加载 token 到内存
  Future<void> init() async {
    _token = await _secureStorage.read(key: _Key.accessToken) ?? "";
    // 同时加载 refresh token（可选，不影响旧逻辑）
    _refreshToken = await _secureStorage.read(key: _Key.refreshToken);
  }

  /// 设置 token（兼容旧接口）
  Future<void> setToken(String val) async {
    await _secureStorage.write(key: _Key.accessToken, value: val);
    _token = val;
  }

  /// 获取 token（同步，返回缓存；未 init 或空时返回 ""）
  String getToken() {
    return _token;
  }

  /// 删除 token（兼容旧接口）
  Future<void> removeToken() async {
    await _secureStorage.delete(key: _Key.accessToken);
    _token = "";
  }

  // ========== 新增 Refresh Token 管理 ==========
  /// 存储 refresh token（登录/刷新时可调用）
  Future<void> setRefreshToken(String token) async {
    await _secureStorage.write(key: _Key.refreshToken, value: token);
    _refreshToken = token;
  }

  /// 获取 refresh token（异步）
  Future<String?> getRefreshToken() async {
    _refreshToken ??= await _secureStorage.read(key: _Key.refreshToken);
    return _refreshToken;
  }

  /// 清除所有 token（退出登录）
  Future<void> clearAll() async {
    await _secureStorage.delete(key: _Key.accessToken);
    await _secureStorage.delete(key: _Key.refreshToken);
    _token = "";
    _refreshToken = null;
  }
}

/// 存储键名常量（私有）
class _Key {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
}

// 导出全局单例
final tokenManager = TokenManager();
