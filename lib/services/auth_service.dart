import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUsername = 'username';
  static const String _keyRegisteredUsers = 'registered_users';

  // Simpan status login
  static Future<void> saveLoginStatus(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyUsername, username);
  }

  // Cek apakah user sudah login
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // Ambil username yang tersimpan
  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsername);
  }

  // Logout - hapus data login
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyUsername);
  }
  // Login sederhana (validasi username dan password)
  static bool validateLogin(String username, String password) {
    // Validasi sederhana saja yaaa - bisa diganti dengan validasi yang lebih kompleks
    return username.isNotEmpty && password.isNotEmpty && password.length >= 4;
  }

  // Registrasi user baru
  static Future<void> registerUser(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> registeredUsers = prefs.getStringList(_keyRegisteredUsers) ?? [];
    
    // Simpan dalam format "username:password"
    registeredUsers.add('$username:$password');
    await prefs.setStringList(_keyRegisteredUsers, registeredUsers);
  }

  // Cek apakah user sudah terdaftar
  static Future<bool> checkUserExists(String username) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> registeredUsers = prefs.getStringList(_keyRegisteredUsers) ?? [];
    
    return registeredUsers.any((user) => user.startsWith('$username:'));
  }

  // Login dengan validasi user terdaftar
  static Future<bool> loginUser(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> registeredUsers = prefs.getStringList(_keyRegisteredUsers) ?? [];
    
    // Cek apakah kombinasi username:password ada
    return registeredUsers.contains('$username:$password');
  }
}
