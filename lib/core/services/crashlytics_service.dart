import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// A service class that handles all crashlytics-related functionality
class CrashlyticsService {
  // Private constructor to prevent instantiation
  CrashlyticsService._();

  // Core service
  static final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  /// Initialize the crashlytics service
  static Future<void> initialize() async {
    try {
      // Only enable Crashlytics in non-debug mode
      await _crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);
      return Future.value();
    } catch (e, stack) {
      print('Failed to initialize Crashlytics: $e');
      return Future.error(e, stack);
    }
  }

  /// Log a message to Crashlytics
  static Future<void> log(String message) async {
    try {
      await _crashlytics.log(message);
      return Future.value();
    } catch (e) {
      print('Failed to log message: $e');
      return Future.error(e);
    }
  }

  /// Record a non-fatal error
  static Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    bool fatal = false,
  }) async {
    try {
      await _crashlytics.recordError(exception, stack, fatal: fatal);
      return Future.value();
    } catch (e) {
      print('Failed to record error: $e');
      return Future.error(e);
    }
  }

  /// Set a custom key to help with debugging
  static Future<void> setCustomKey(String key, dynamic value) async {
    try {
      await _crashlytics.setCustomKey(key, value);
      return Future.value();
    } catch (e) {
      print('Failed to set custom key: $e');
      return Future.error(e);
    }
  }

  /// Set user identifier to track issues by user
  static Future<void> setUserIdentifier(String identifier) async {
    try {
      await _crashlytics.setUserIdentifier(identifier);
      return Future.value();
    } catch (e) {
      print('Failed to set user identifier: $e');
      return Future.error(e);
    }
  }

  /// Force a crash for testing purposes (only in non-production)
  static void forceCrash() {
    if (!kReleaseMode) {
      try {
        _crashlytics.crash();
      } catch (e) {
        print('Failed to force crash: $e');
      }
    }
  }
}
