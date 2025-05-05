import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../utils/auth_error_handler.dart';
import '../../utils/app_theme.dart';
// import '../../utils/ui_components.dart'; // Removing dependency on UIComponents
// Import platform check
import 'dart:io' show Platform;

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final authNotifier = ref.read(authNotifierProvider.notifier);
        await authNotifier.registerWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _nameController.text.trim(),
        );
        if (mounted) {
          Navigator.pop(
            context,
          ); // Go back to login screen after successful registration
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage = AuthErrorHandler.handleError(e);
          });
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign up'), // Updated title to match inspiration
        centerTitle: false,
        elevation: 0,
        backgroundColor: AppTheme.getBackgroundColor(isDark),
      ),
      backgroundColor: AppTheme.getBackgroundColor(isDark),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title
                  Text(
                    'Sign up', // Consistent with AppBar title
                    style: AppTheme.getHeadingStyle(
                      isDark,
                    ).copyWith(fontSize: 32),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 32),

                  // Name field with Label
                  Text(
                    'Name', // Label text
                    style: AppTheme.getSmallStyle(isDark).copyWith(
                      color: AppTheme.getSecondaryTextColor(isDark),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    decoration: AppTheme.getInputDecoration(
                      context: context,
                      labelText: 'Enter your name',
                      prefixIcon: null, // Remove icon
                    ).copyWith(
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      labelStyle: AppTheme.getBodyStyle(isDark).copyWith(
                        color:
                            isDark
                                ? AppTheme.darkTertiaryText
                                : AppTheme.lightTertiaryText,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Email field with Label
                  Text(
                    'Email', // Label text
                    style: AppTheme.getSmallStyle(isDark).copyWith(
                      color: AppTheme.getSecondaryTextColor(isDark),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    decoration: AppTheme.getInputDecoration(
                      context: context,
                      labelText: 'Enter your email address',
                      prefixIcon: null, // Remove icon
                    ).copyWith(
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      labelStyle: AppTheme.getBodyStyle(isDark).copyWith(
                        color:
                            isDark
                                ? AppTheme.darkTertiaryText
                                : AppTheme.lightTertiaryText,
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Password field with Label
                  Text(
                    'Create a password', // Label text from inspiration
                    style: AppTheme.getSmallStyle(isDark).copyWith(
                      color: AppTheme.getSecondaryTextColor(isDark),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    decoration: AppTheme.getInputDecoration(
                      context: context,
                      labelText:
                          'must be 8 characters', // Hint text from inspiration
                      prefixIcon: null, // Remove icon
                      suffixIcon: IconButton(
                        // Add suffix icon for visibility toggle
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color:
                              isDark
                                  ? AppTheme.darkTertiaryText
                                  : AppTheme.lightTertiaryText,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ).copyWith(
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      labelStyle: AppTheme.getBodyStyle(isDark).copyWith(
                        color:
                            isDark
                                ? AppTheme.darkTertiaryText
                                : AppTheme.lightTertiaryText,
                      ),
                    ),
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 6) {
                        // Keep 6 char validation for now unless spec changes
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Confirm Password field with Label
                  Text(
                    'Confirm password', // Label text from inspiration
                    style: AppTheme.getSmallStyle(isDark).copyWith(
                      color: AppTheme.getSecondaryTextColor(isDark),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: AppTheme.getInputDecoration(
                      context: context,
                      labelText:
                          'repeat password', // Hint text from inspiration
                      prefixIcon: null, // Remove icon
                      suffixIcon: IconButton(
                        // Add suffix icon for visibility toggle
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color:
                              isDark
                                  ? AppTheme.darkTertiaryText
                                  : AppTheme.lightTertiaryText,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ).copyWith(
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      labelStyle: AppTheme.getBodyStyle(isDark).copyWith(
                        color:
                            isDark
                                ? AppTheme.darkTertiaryText
                                : AppTheme.lightTertiaryText,
                      ),
                    ),
                    obscureText: _obscureConfirmPassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32), // Increased spacing before button
                  // Error message
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color:
                              isDark
                                  ? Colors.red.shade300
                                  : Colors.red.shade700,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // Sign up Button
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _register,
                      style: AppTheme.getPrimaryButtonStyle(
                        context,
                      ), // Use theme style
                      child:
                          _isLoading
                              ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text(
                                'Sign up',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                    ),
                  ),
                  const SizedBox(
                    height: 24,
                  ), // Spacing before social/login link
                  // --- Social Register Divider and Buttons ---
                  Row(
                    children: [
                      Expanded(
                        child: Divider(color: AppTheme.getDividerColor(isDark)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Or Sign up with',
                          style: AppTheme.getSmallStyle(isDark),
                        ),
                      ),
                      Expanded(
                        child: Divider(color: AppTheme.getDividerColor(isDark)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Google Sign In Button
                      OutlinedButton(
                        onPressed: () {
                          // TODO: Implement Google Sign Up/Link
                          print('Google Sign Up tapped');
                          // ref.read(authNotifierProvider.notifier).signInWithGoogle(); // Might need different logic for register
                        },
                        style: AppTheme.getSecondaryButtonStyle(
                          context,
                        ), // Use secondary style
                        child: Image.asset(
                          'assets/images/google_logo.png', // Reuse logo asset
                          height: 24.0,
                          width: 24.0,
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Apple Sign In Button (Only show on iOS/macOS)
                      if (Platform.isIOS || Platform.isMacOS)
                        OutlinedButton(
                          onPressed: () {
                            // TODO: Implement Apple Sign Up/Link
                            print('Apple Sign Up tapped');
                            // ref.read(authNotifierProvider.notifier).signInWithApple(); // Might need different logic
                          },
                          style: AppTheme.getSecondaryButtonStyle(
                            context,
                          ).copyWith(
                            foregroundColor: MaterialStateProperty.all(
                              AppTheme.getPrimaryTextColor(isDark),
                            ),
                          ),
                          child: Icon(
                            Icons.apple,
                            size: 28.0,
                            color: AppTheme.getPrimaryTextColor(isDark),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // --- End Social Register ---

                  // Log in link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
                        style: AppTheme.getBodyStyle(
                          isDark,
                        ).copyWith(fontSize: 14),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: AppTheme.getTextButtonStyle(context).copyWith(
                          padding: MaterialStateProperty.all(
                            const EdgeInsets.symmetric(horizontal: 4.0),
                          ),
                        ),
                        child: Text(
                          'Log in',
                          style: AppTheme.getBodyStyle(isDark).copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.getPrimaryColor(isDark),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16), // Bottom padding
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
