import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Model to hold user preferences
class UserPreferences {
  final bool hasCompletedOnboarding;
  final bool rememberMe;
  final String? savedEmail;

  UserPreferences({
    required this.hasCompletedOnboarding,
    this.rememberMe = false,
    this.savedEmail,
  });

  UserPreferences copyWith({
    bool? hasCompletedOnboarding,
    bool? rememberMe,
    String? savedEmail,
  }) {
    return UserPreferences(
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      rememberMe: rememberMe ?? this.rememberMe,
      savedEmail: savedEmail ?? this.savedEmail,
    );
  }
}

// Provider to manage user preferences
class PreferencesNotifier extends StateNotifier<UserPreferences> {
  static const String _onboardingKey = 'has_completed_onboarding';
  static const String _rememberMeKey = 'remember_me';
  static const String _savedEmailKey = 'saved_email';
  late SharedPreferences _prefs;

  PreferencesNotifier()
    : super(UserPreferences(hasCompletedOnboarding: false)) {
    _initPreferences();
  }

  Future<void> _initPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    final hasCompletedOnboarding = _prefs.getBool(_onboardingKey) ?? false;
    final rememberMe = _prefs.getBool(_rememberMeKey) ?? false;
    final savedEmail = _prefs.getString(_savedEmailKey);

    state = UserPreferences(
      hasCompletedOnboarding: hasCompletedOnboarding,
      rememberMe: rememberMe,
      savedEmail: savedEmail,
    );
  }

  Future<void> setOnboardingCompleted(bool completed) async {
    await _prefs.setBool(_onboardingKey, completed);
    state = state.copyWith(hasCompletedOnboarding: completed);
  }

  Future<void> setRememberMe(bool remember, {String? email}) async {
    await _prefs.setBool(_rememberMeKey, remember);
    if (remember && email != null) {
      await _prefs.setString(_savedEmailKey, email);
      state = state.copyWith(rememberMe: remember, savedEmail: email);
    } else if (!remember) {
      await _prefs.remove(_savedEmailKey);
      state = state.copyWith(rememberMe: false, savedEmail: null);
    } else {
      state = state.copyWith(rememberMe: remember);
    }
  }
}

// Create the provider
final preferencesProvider =
    StateNotifierProvider<PreferencesNotifier, UserPreferences>((ref) {
      return PreferencesNotifier();
    });
