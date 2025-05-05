import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../utils/auth_error_handler.dart';
import '../../utils/app_theme.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import 'dart:io' show Platform;

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;
  bool _isGoogleLoading = false; // Loading state for Google
  bool _isAppleLoading = false;  // Loading state for Apple

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Loading state for email/password
        _errorMessage = null;
      });

      try {
        final authNotifier = ref.read(authNotifierProvider.notifier);
        await authNotifier.signInWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
        // On success, AuthWrapper handles navigation
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

  // --- Google Sign In Handler ---
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isGoogleLoading = true;
      _errorMessage = null;
    });
    try {
      final authNotifier = ref.read(authNotifierProvider.notifier);
      await authNotifier.signInWithGoogle();
      // On success, AuthWrapper handles navigation
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = AuthErrorHandler.handleError(e);
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  // --- Apple Sign In Handler ---
  Future<void> _signInWithApple() async {
    // Important: Apple Sign In only works on iOS/macOS physical devices or simulators
    // and requires additional setup in Xcode and Apple Developer Portal.
    if (!Platform.isIOS && !Platform.isMacOS) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Apple Sign-In is only available on iOS and macOS.')),
      );
      return;
    }

    setState(() {
      _isAppleLoading = true;
      _errorMessage = null;
    });
    try {
      final authNotifier = ref.read(authNotifierProvider.notifier);
      await authNotifier.signInWithApple();
      // On success, AuthWrapper handles navigation
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = AuthErrorHandler.handleError(e);
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAppleLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // final size = MediaQuery.of(context).size; // Not strictly needed for this layout

    return Scaffold(
      // Use AppBar for back button and consistent title style
      appBar: AppBar(
        title: const Text('Log in'),
        centerTitle:
            false, // Align title left as per inspiration? No title shown, let's remove it maybe? Or keep for context. Let's keep AppBar for back nav.
        elevation: 0,
        backgroundColor: AppTheme.getBackgroundColor(
          isDark,
        ), // Match background
      ),
      backgroundColor: AppTheme.getBackgroundColor(
        isDark,
      ), // Ensure scaffold matches AppBar
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ), // Adjusted padding
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Decorative Icon (optional, using wallet icon as placeholder)
                  // Align(
                  //   alignment: Alignment.topRight,
                  //   child: Icon(
                  //     Icons.star_border, // Placeholder for the star icon
                  //     color: AppTheme.getPrimaryTextColor(isDark).withOpacity(0.5),
                  //     size: 32,
                  //   ),
                  // ),
                  // const SizedBox(height: 24),

                  // Title
                  Text(
                    'Log in', // Using the AppBar title now, so maybe remove this? Inspiration has it large. Let's keep it large.
                    style: AppTheme.getHeadingStyle(
                      isDark,
                    ).copyWith(fontSize: 32), // Larger title
                    textAlign: TextAlign.left, // Left align title
                  ),
                  // Optional Subtitle/Description
                  // Text(
                  //   'Welcome back', // Kept from previous version
                  //   style: AppTheme.getBodyStyle(isDark),
                  //   textAlign: TextAlign.center,
                  // ),
                  const SizedBox(height: 32), // Increased spacing
                  // Email field with Label
                  Text(
                    'Email address', // Label text
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
                      labelText:
                          'Enter your email address', // Use labelText as hint
                      prefixIcon: null, // Remove prefix icon for cleaner look
                    ).copyWith(
                      floatingLabelBehavior:
                          FloatingLabelBehavior
                              .never, // Prevent label from floating
                      labelStyle: AppTheme.getBodyStyle(isDark).copyWith(
                        color:
                            isDark
                                ? AppTheme.darkTertiaryText
                                : AppTheme.lightTertiaryText,
                      ), // Style hint
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
                  const SizedBox(height: 20), // Consistent spacing
                  // Password field with Label
                  Text(
                    'Password', // Label text
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
                      labelText: 'Enter your password', // Use labelText as hint
                      prefixIcon: null, // Remove prefix icon
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
                      floatingLabelBehavior:
                          FloatingLabelBehavior
                              .never, // Prevent label from floating
                      labelStyle: AppTheme.getBodyStyle(isDark).copyWith(
                        color:
                            isDark
                                ? AppTheme.darkTertiaryText
                                : AppTheme.lightTertiaryText,
                      ), // Style hint
                    ),
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16), // Spacing before forgot password
                  // Forgot password link (Align right)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
                      style: AppTheme.getTextButtonStyle(context).copyWith(
                        // Use theme style
                        padding: MaterialStateProperty.all(
                          EdgeInsets.zero,
                        ), // Remove extra padding
                      ),
                      child: Text(
                        'Forgot password?',
                        style: AppTheme.getSmallStyle(isDark).copyWith(
                          color: AppTheme.getPrimaryColor(isDark),
                          fontWeight: FontWeight.w500,
                        ), // Match inspiration style
                      ),
                    ),
                  ),
                  const SizedBox(height: 24), // Spacing before error/button
                  // Error message
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // Login button (Primary Action)
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
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
                              : Text(
                                'Log in',
                                style: AppTheme.getBodyStyle(isDark).copyWith(
                                  fontWeight: FontWeight.w500,
                                  color:
                                      isDark
                                          ? AppTheme.primaryBlack
                                          : AppTheme.white,
                                ),
                              ), // Match inspiration text, ensure contrast
                    ),
                  ),
                  const SizedBox(height: 24), // Spacing before social/signup
                  // --- Social Login Divider and Buttons ---
                  Row(
                    children: [
                      Expanded(
                        child: Divider(color: AppTheme.getDividerColor(isDark)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Or Log in with',
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
                        onPressed: _isGoogleLoading || _isAppleLoading ? null : _signInWithGoogle,
                        style: AppTheme.getOutlinedSocialButtonStyle(context),
                        child: _isGoogleLoading
                            ? const SizedBox(
                                height: 24.0,
                                width: 24.0,
                                child: CircularProgressIndicator(strokeWidth: 2.0),
                              )
                            : Image.asset('assets/images/google_logo.png', height: 24),
                      ),
                      const SizedBox(width: 16),

                      // Apple Sign In Button (Only show on iOS/macOS)
                      if (Platform.isIOS || Platform.isMacOS)
                        OutlinedButton(
                          onPressed: _isGoogleLoading || _isAppleLoading ? null : _signInWithApple,
                          style: AppTheme.getOutlinedSocialButtonStyle(context).copyWith(
                             backgroundColor: MaterialStateProperty.resolveWith<Color?>((states) {
                                return Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black;
                             }),
                             foregroundColor: MaterialStateProperty.resolveWith<Color?>((states) {
                                return Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white;
                             }),
                          ),
                          child: _isAppleLoading
                              ? SizedBox(
                                  height: 24.0,
                                  width: 24.0,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.0,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
                                    ),
                                  ),
                                )
                              : Icon(
                                  Icons.apple, // Using a generic Apple icon
                                  size: 28, // Slightly larger to match visual weight
                                  color: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
                                ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // --- End Social Login ---

                  // Sign up link (Centered)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: AppTheme.getBodyStyle(
                          isDark,
                        ).copyWith(fontSize: 14), // Use theme style
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate without replacing, so user can go back
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                        style: AppTheme.getTextButtonStyle(context).copyWith(
                          // Use theme style
                          padding: MaterialStateProperty.all(
                            const EdgeInsets.symmetric(horizontal: 4.0),
                          ), // Adjust padding
                        ),
                        child: Text(
                          'Sign up',
                          style: AppTheme.getBodyStyle(isDark).copyWith(
                            // Use theme style
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
