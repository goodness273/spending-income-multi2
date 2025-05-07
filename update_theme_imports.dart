import 'dart:io';

// Simple logger function to avoid using print directly
void log(String message) {
  // In a real app, you'd use a proper logging framework
  // For this script, we'll still output to console but through this function
  stdout.writeln(message);
}

void main() async {
  // List of files to update
  final filesToUpdate = [
    'lib/screens/transactions/transactions_screen.dart',
    'lib/screens/transactions/add_transaction/transaction_method_selector.dart',
    'lib/screens/transactions/add_transaction/manual_form_interface.dart',
    'lib/screens/transactions/add_transaction/ai_chat_interface.dart',
    'lib/screens/splash_screen.dart',
    'lib/screens/onboarding/onboarding_screen.dart',
    'lib/screens/onboarding/onboarding_page.dart',
    'lib/screens/home/home_screen.dart',
    'lib/screens/auth/register_screen.dart',
    'lib/screens/auth/login_screen.dart',
    'lib/screens/auth/forgot_password_screen.dart',
  ];

  for (final filePath in filesToUpdate) {
    await updateFile(filePath);
  }

  log('All files updated successfully!');
}

Future<void> updateFile(String filePath) async {
  try {
    final file = File(filePath);
    if (!await file.exists()) {
      log('File not found: $filePath');
      return;
    }

    String content = await file.readAsString();
    
    // Update import statement
    final importPattern = RegExp("import [\"'].*app_theme\\.dart[\"'];");
    content = content.replaceAll(
      importPattern,
      'import \'package:spending_income/utils/app_theme/index.dart\';'
    );

    // Update color references
    final colorPattern = RegExp("AppTheme\\.([a-zA-Z]+)(?!\\()");
    content = content.replaceAllMapped(
      colorPattern,
      (match) => 'AppColors.${match[1]}'
    );

    // Update helper methods
    final helperPattern = RegExp("AppTheme\\.(get[a-zA-Z]+?)");
    content = content.replaceAllMapped(
      helperPattern,
      (match) => 'AppThemeHelpers.${match[1]}'
    );

    // Update button styles
    final buttonPattern = RegExp("AppTheme\\.(get.*ButtonStyle)");
    content = content.replaceAllMapped(
      buttonPattern,
      (match) => 'AppButtonStyles.${match[1]}'
    );

    // Update theme building methods
    final themePattern = RegExp("AppTheme\\.(build.*Theme)");
    content = content.replaceAllMapped(
      themePattern,
      (match) => 'AppThemeBuilder.${match[1]}'
    );
    
    // Update text styles
    final stylePattern = RegExp("AppTheme\\.([a-zA-Z]+Style)");
    content = content.replaceAllMapped(
      stylePattern,
      (match) => 'AppTextStyles.${match[1]}'
    );

    // Write the updated content back to the file
    await file.writeAsString(content);
    log('Updated: $filePath');
  } catch (e) {
    log('Error updating $filePath: $e');
  }
} 