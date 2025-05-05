import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spending_income/screens/auth/login_screen.dart';
import 'package:spending_income/screens/auth/register_screen.dart';
import 'package:spending_income/screens/auth/forgot_password_screen.dart';

void main() {
  testWidgets('Login screen UI test', (WidgetTester tester) async {
    // Build our login screen and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: LoginScreen())),
    );

    // Verify that the title is displayed
    expect(find.text('Spending & Income Tracker'), findsOneWidget);

    // Verify that the email and password fields are displayed
    expect(find.byType(TextFormField), findsNWidgets(2));

    // Verify that the login button is displayed using a more specific finder
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);

    // Verify that the sign up link is displayed
    expect(find.text("Don't have an account?"), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Sign Up'), findsOneWidget);
  });

  testWidgets('Register screen UI test', (WidgetTester tester) async {
    // Build our register screen and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: RegisterScreen())),
    );

    // Verify that the title is displayed
    expect(find.text('Join Spending & Income Tracker'), findsOneWidget);

    // Verify that all form fields are displayed
    expect(find.byType(TextFormField), findsNWidgets(4));

    // Verify that the create account button is displayed using a more specific finder
    expect(
      find.widgetWithText(ElevatedButton, 'Create Account'),
      findsOneWidget,
    );

    // Verify that the login link is displayed
    expect(find.text('Already have an account?'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Log In'), findsOneWidget);
  });

  testWidgets('Navigate from login to register screen', (
    WidgetTester tester,
  ) async {
    // Build our login screen and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: LoginScreen())),
    );

    // Tap the sign up button with more specific finder
    await tester.tap(find.widgetWithText(TextButton, 'Sign Up'));
    await tester.pumpAndSettle();

    // Verify that we're on the register screen
    expect(find.text('Join Spending & Income Tracker'), findsOneWidget);
  });

  testWidgets('Login form validation test', (WidgetTester tester) async {
    // Build our login screen and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: LoginScreen())),
    );

    // Try to login without filling the form using more specific finder
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();

    // Verify validation errors are displayed
    expect(find.text('Please enter your email'), findsOneWidget);
    expect(find.text('Please enter your password'), findsOneWidget);
  });

  testWidgets('Register form validation test', (WidgetTester tester) async {
    // Build our register screen and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: RegisterScreen())),
    );

    // Try to register without filling the form using more specific finder
    await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
    await tester.pump();

    // Verify validation errors are displayed
    expect(find.text('Please enter your name'), findsOneWidget);
    expect(find.text('Please enter your email'), findsOneWidget);
    expect(find.text('Please enter a password'), findsOneWidget);
    expect(find.text('Please confirm your password'), findsOneWidget);
  });

  testWidgets('Forgot password screen UI test', (WidgetTester tester) async {
    // Build our forgot password screen and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: ForgotPasswordScreen())),
    );

    // Verify that the title is displayed
    expect(find.text('Forgot Your Password?'), findsOneWidget);

    // Verify that the email field is displayed
    expect(find.byType(TextFormField), findsOneWidget);

    // Verify that the reset password button is displayed using more specific finder
    expect(
      find.widgetWithText(ElevatedButton, 'Reset Password'),
      findsOneWidget,
    );

    // Verify that the login link is displayed
    expect(find.text('Remember your password?'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Login'), findsOneWidget);
  });

  testWidgets('Navigate from login to forgot password screen', (
    WidgetTester tester,
  ) async {
    // Build our login screen and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: LoginScreen())),
    );

    // Tap the forgot password button using more specific finder
    await tester.tap(find.widgetWithText(TextButton, 'Forgot Password?'));
    await tester.pumpAndSettle();

    // Verify that we're on the forgot password screen
    expect(find.text('Forgot Your Password?'), findsOneWidget);
  });

  testWidgets('Forgot password form validation test', (
    WidgetTester tester,
  ) async {
    // Build our forgot password screen and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: ForgotPasswordScreen())),
    );

    // Try to reset password without filling the form using more specific finder
    await tester.tap(find.widgetWithText(ElevatedButton, 'Reset Password'));
    await tester.pump();

    // Verify validation error is displayed
    expect(find.text('Please enter your email'), findsOneWidget);
  });
}
