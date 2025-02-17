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

  // Method to log in the user with fake credentials
  bool logInWithCredentials(String email, String password) {
    // Fake credentials
    const fakeEmail = 'user@example.com';
    const fakePassword = 'password123';

    if (email == fakeEmail && password == fakePassword) {
      _isLoggedIn = true;
      return true;
    }
    return false;
  }
}
