import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Model to hold user preferences
class UserPreferences {
  final bool hasCompletedOnboarding;

  UserPreferences({required this.hasCompletedOnboarding});

  UserPreferences copyWith({bool? hasCompletedOnboarding}) {
    return UserPreferences(
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
    );
  }
}

// Provider to manage user preferences
class PreferencesNotifier extends StateNotifier<UserPreferences> {
  static const String _onboardingKey = 'has_completed_onboarding';
  late SharedPreferences _prefs;

  PreferencesNotifier()
    : super(UserPreferences(hasCompletedOnboarding: false)) {
    _initPreferences();
  }

  Future<void> _initPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    final hasCompletedOnboarding = _prefs.getBool(_onboardingKey) ?? false;

    state = UserPreferences(hasCompletedOnboarding: hasCompletedOnboarding);
  }

  Future<void> setOnboardingCompleted(bool completed) async {
    await _prefs.setBool(_onboardingKey, completed);
    state = state.copyWith(hasCompletedOnboarding: completed);
  }
}

// Create the provider
final preferencesProvider =
    StateNotifierProvider<PreferencesNotifier, UserPreferences>((ref) {
      return PreferencesNotifier();
    });
