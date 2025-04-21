import 'package:flutter_life_goal_management/src/services/user_service.dart';
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
  void logOut() {
    _isLoggedIn = false;
  }

  void setToken(String token) {
    _token = token;
  }

  String? getToken() {
    return _token;
  }

  // Method to get the logged-in user's information
  User? getLoggedInUser() {
    return _loggedInUser;
  }

  // Method to log in the user with fake credentials
  Future<bool> logInWithCredentials(String email, String password) async {
    print("Email: $email");
    print("Password: $password");
    final token = await UserService().login(email, password);
    print("Token: $token");
    if (token != null) {
      _isLoggedIn = true;
      setToken(token);
      _loggedInUser = await UserService().getUser();
      return true;
    }
    return false;
  }
}
