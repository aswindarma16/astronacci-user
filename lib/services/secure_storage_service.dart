import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// to manage session, only save username because offline and no token or other sensitive data used
class SecureStorageService {
  static const _storage = FlutterSecureStorage();

  // Keys
  static const _userKey = 'userName';
  static const _usersListKey = 'registered_users';

  // For session management
  static Future<void> saveUser(String userName) async {
    await _storage.write(key: _userKey, value: userName);
  }

  static Future<String?> getUser() async {
    return await _storage.read(key: _userKey);
  }

  static Future<void> deleteUser() async {
    await _storage.delete(key: _userKey);
  }


  // For register user
  static Future<List<Map<String, dynamic>>> getRegisteredUsers() async {
    final jsonString = await _storage.read(key: _usersListKey);
    if (jsonString == null || jsonString.isEmpty) return [];
    final List decoded = json.decode(jsonString);
    return decoded.cast<Map<String, dynamic>>();
  }

  static Future<void> saveRegisteredUsers(List<Map<String, dynamic>> users) async {
    final jsonString = json.encode(users);
    await _storage.write(key: _usersListKey, value: jsonString);
  }

  static Future<void> addUser(String username, String password) async {
    final users = await getRegisteredUsers();

    final exists = users.any((u) => u['username'] == username);
    if (exists) {
      throw Exception("Username already taken");
    }

    users.add({
      "username": username,
      "password": password,
    });

    await saveRegisteredUsers(users);
  }
}