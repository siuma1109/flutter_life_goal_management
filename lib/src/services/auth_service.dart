import '../services/database_helper.dart';
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

  // Method to get the logged-in user's information
  User? getLoggedInUser() {
    return _loggedInUser;
  }

  // Method to log in the user with fake credentials
  Future<bool> logInWithCredentials(
      String emailOrUsername, String password) async {
    final databaseHelper = DatabaseHelper();
    final user = await databaseHelper.getUserByEmailOrUsername(emailOrUsername);
    if (user != null && user.password == password) {
      _isLoggedIn = true;
      _loggedInUser = user; // Store the logged-in user's information
      return true;
    }
    return false;
  }
}
