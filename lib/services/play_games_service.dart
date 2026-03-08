import 'package:flutter/foundation.dart';
import 'package:games_services/games_services.dart';

/// Google Play Games Service for WeedEmpire.
/// Handles sign-in, achievements, and leaderboards.
class PlayGamesService {
  static final PlayGamesService _instance = PlayGamesService._internal();
  factory PlayGamesService() => _instance;
  PlayGamesService._internal();

  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;

  /// Sign in to Google Play Games
  Future<void> signIn() async {
    try {
      await GamesServices.signIn();
      _isSignedIn = true;
      debugPrint('PlayGamesService: Signed in successfully.');
    } catch (e) {
      _isSignedIn = false;
      debugPrint('PlayGamesService: Sign-in failed: $e');
    }
  }

  /// Show the player's Play Games achievements (acts as profile view)
  Future<void> showDashboard() async {
    try {
      await GamesServices.showAchievements();
    } catch (e) {
      debugPrint('PlayGamesService: Dashboard error: $e');
    }
  }

  /// Show the achievements screen
  Future<void> showAchievements() async {
    try {
      await GamesServices.showAchievements();
    } catch (e) {
      debugPrint('PlayGamesService: Achievements error: $e');
    }
  }

  /// Unlock an achievement by ID
  Future<void> unlockAchievement(String id) async {
    try {
      await GamesServices.unlock(
        achievement: Achievement(androidID: id),
      );
    } catch (e) {
      debugPrint('PlayGamesService: Achievement unlock error: $e');
    }
  }

  /// Show the leaderboard screen
  Future<void> showLeaderboard() async {
    try {
      await GamesServices.showLeaderboards();
    } catch (e) {
      debugPrint('PlayGamesService: Leaderboard error: $e');
    }
  }

  /// Submit a score to a leaderboard
  Future<void> submitScore(String leaderboardId, int score) async {
    try {
      await GamesServices.submitScore(
        score: Score(
          androidLeaderboardID: leaderboardId,
          value: score,
        ),
      );
    } catch (e) {
      debugPrint('PlayGamesService: Score submit error: $e');
    }
  }
}
