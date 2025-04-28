import 'package:flutter_life_goal_management/src/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  // Singleton instance
  static final AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  // This is a placeholder for the actual authentication state.
  // In a real application, this might be replaced with a more complex logic
  // involving secure storage, API calls, etc.
  bool _isLoggedIn = false;
  String? _token;

  // Add a private variable to store the logged-in user's information
  User? _loggedInUser;

  // Method to check if the user is logged in
  bool isLoggedIn() {
    return _isLoggedIn;
  }

  // Method to log in the user
  void logIn() {
    _isLoggedIn = true;
  }

  // Method to log out the user
  Future<void> logOut() async {
    _isLoggedIn = false;
    _loggedInUser = null;
    await deleteToken();
  }

  // Save token to SharedPreferences
  Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  // Delete token from SharedPreferences
  Future<void> deleteToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  // Get token from SharedPreferences
  Future<String?> getToken() async {
    if (_token != null) return _token;

    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    return _token;
  }

  // Method to get the logged-in user's information
  User? getLoggedInUser() {
    return _loggedInUser;
  }

  void setLoggedInUser(User user) {
    _loggedInUser = user;
  }

  // Method to log in the user with credentials
  Future<bool> logInWithCredentials(String email, String password) async {
    final token = await UserService().login(email, password);

    if (token != null) {
      _isLoggedIn = true;
      await setToken(token);
      _loggedInUser = await UserService().getUser();
      return true;
    }
    return false;
  }

  Future<bool> register(String email, String password, String name) async {
    final result = await UserService().register(email, password, name);
    if (result != null) {
      _isLoggedIn = true;
      await setToken(result['token']);
      return true;
    }
    return false;
  }

  // Check if user is logged in based on token
  Future<bool> loggedIn() async {
    // First check if we have a token
    final token = await getToken();

    if (token == null || token.isEmpty) {
      _isLoggedIn = false;
      return false;
    }

    // If we have a token, validate it by getting user info
    final result = await UserService().getUser();

    if (result != null) {
      _isLoggedIn = true;
      _loggedInUser = result;
      return true;
    } else {
      // If token is invalid, delete it
      await deleteToken();
      _loggedInUser = null;
      _isLoggedIn = false;
      return false;
    }
  }
}
