import 'package:shared_preferences/shared_preferences.dart';

/// Temporary local free-usage manager.
///
/// IMPORTANT:
/// SharedPreferences is deleted when the app is uninstalled.
/// When login is added later, replace this storage with Firebase using the UID.
/// The rest of the screens can keep calling this same class.
class StoryFreeUsageManager {
  StoryFreeUsageManager._();

  static const int freeStoryLimit = 1;
  static const String _storyCountKey = 'freeStorySuccessfulCountV1';

  /// Number of successfully generated free stories on this installation.
  static Future<int> getStoryCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_storyCountKey) ?? 0;
  }

  /// true when a non-subscriber may still create a free story.
  static Future<bool> canCreateFreeStory() async {
    final count = await getStoryCount();
    return count < freeStoryLimit;
  }

  /// Call this ONLY after a free story has generated successfully.
  ///
  /// It intentionally caps the value at [freeStoryLimit], because currently
  /// there is only one free story.
  static Future<void> markFreeStorySuccessfullyGenerated() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_storyCountKey) ?? 0;

    if (current >= freeStoryLimit) return;

    await prefs.setInt(_storyCountKey, current + 1);
  }

  /// Convenience check for your Create Story button.
  ///
  /// Returns true when generation is allowed:
  /// - subscribed users are always allowed
  /// - free users are allowed until they use their one successful free story
  static Future<bool> canCreateStory({
    required bool isSubscription,
  }) async {
    if (isSubscription) return true;
    return canCreateFreeStory();
  }


  /// For debug/testing only.
  /// Do not expose this to normal users.
  static Future<void> resetForTesting() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storyCountKey);
  }
}
