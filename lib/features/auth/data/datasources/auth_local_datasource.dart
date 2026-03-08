import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<UserModel?> getCachedUser();
  Future<void> cacheUser(UserModel user);
  Future<void> clearCachedUser();
  Future<bool> isLoggedIn();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _userKey = 'cached_user';
  static const String _tokenKey = 'auth_token';

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final jsonString = sharedPreferences.getString(_userKey);
      if (jsonString == null) return null;
      final decoded = json.decode(jsonString);

      // Defensive: if stored value is not a Map (e.g., a List), clear it and return null
      if (decoded is! Map<String, dynamic>) {
        // Clear the corrupt/legacy cached value to avoid future crashes
        await sharedPreferences.remove(_userKey);
        return null;
      }

      return UserModel.fromJson(decoded);
    } catch (e) {
      throw CacheException(message: 'فشل قراءة بيانات المستخدم المخزنة');
    }
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      await sharedPreferences.setString(
        _userKey,
        json.encode(user.toJson()),
      );
    } catch (e) {
      throw CacheException(message: 'فشل حفظ بيانات المستخدم');
    }
  }

  @override
  Future<void> clearCachedUser() async {
    try {
      await sharedPreferences.remove(_userKey);
      await sharedPreferences.remove(_tokenKey);
    } catch (e) {
      throw CacheException(message: 'فشل حذف بيانات المستخدم');
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    return sharedPreferences.containsKey(_userKey);
  }
}
