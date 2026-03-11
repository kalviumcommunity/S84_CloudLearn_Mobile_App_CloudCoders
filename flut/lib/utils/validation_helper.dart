/// ValidationHelper provides utility functions for input validation
/// Used throughout the app to validate user inputs like emails, passwords, and names
class ValidationHelper {
  /// Validates if the input is a valid email format
  /// Returns true if email is valid, false otherwise
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email.trim());
  }

  /// Validates if the password meets minimum requirements
  /// - Minimum 6 characters
  /// - At least one uppercase letter
  /// - At least one number
  static bool isValidPassword(String password) {
    if (password.length < 6) return false;
    if (!password.contains(RegExp(r'[A-Z]'))) return false;
    if (!password.contains(RegExp(r'[0-9]'))) return false;
    return true;
  }

  /// Validates if the name is not empty and has at least 2 characters
  static bool isValidName(String name) {
    return name.trim().isNotEmpty && name.trim().length >= 2;
  }

  /// Validates if the phone number contains only digits and is between 10-13 digits
  static bool isValidPhoneNumber(String phoneNumber) {
    final phoneRegex = RegExp(r'^[0-9]{10,13}$');
    return phoneRegex.hasMatch(phoneNumber.replaceAll(RegExp(r'[^\d]'), ''));
  }
}
