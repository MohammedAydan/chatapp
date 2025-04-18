import 'dart:convert';

import 'package:chatapp/core/helpers/encryption_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:chatapp/core/services/crashlytics_service.dart';

class PushNotificationService {
  // Cache the access token to avoid frequent authentication
  static String? _accessToken;
  static DateTime? _tokenExpiry;

  // Set to track invalid tokens
  static final Set<String> _invalidTokens = {};

  static Future<String> _getAccessToken() async {
    // Check if we have a valid cached token
    if (_accessToken != null &&
        _tokenExpiry != null &&
        DateTime.now().isBefore(_tokenExpiry!)) {
      return _accessToken!;
    }

    try {
      final jsonString = await rootBundle.loadString(
        "assets/notification_key/chats-b3204-d71bcd5d005b.json",
      );

      final clientCredentials = ServiceAccountCredentials.fromJson(jsonString);
      final scopes = ["https://www.googleapis.com/auth/firebase.messaging"];
      final client = http.Client();

      try {
        final credentials = await obtainAccessCredentialsViaServiceAccount(
          clientCredentials,
          scopes,
          client,
        );

        // Cache the token and set expiry
        _accessToken = credentials.accessToken.data;
        _tokenExpiry = credentials.accessToken.expiry;

        return _accessToken!;
      } finally {
        client.close();
      }
    } catch (e, stack) {
      CrashlyticsService.recordError(e, stack);
      debugPrint("Error obtaining access token: $e");
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> sendNotification({
    required String token,
    Map<String, dynamic>? data,
    String? route,
  }) async {
    // Skip sending if token is already known to be invalid
    if (token.isEmpty || _invalidTokens.contains(token)) {
      debugPrint("Invalid FCM token or token is known to be invalid");
      return {
        'success': false,
        'error': 'INVALID_TOKEN',
        'message': 'Token is empty or known to be invalid',
      };
    }

    try {
      final String accessToken = await _getAccessToken();
      final String fcmUrl =
          "https://fcm.googleapis.com/v1/projects/chats-b3204/messages:send";

      final message = {
        "message": {
          "token": token,
          "data": {
            if (data != null) ...data,
            if (route != null) "route": route,
          },
        },
      };

      final response = await http.post(
        Uri.parse(fcmUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken",
        },
        body: jsonEncode(message),
      );

      if (response.statusCode == 200) {
        debugPrint("✅ Notification sent successfully");
        return {'success': true};
      } else {
        Map<String, dynamic> errorResponse;
        try {
          errorResponse = jsonDecode(response.body);
        } catch (e, stack) {
          CrashlyticsService.recordError(e, stack);
          errorResponse = {'error': 'Failed to parse error response'};
        }

        debugPrint("❌ Failed to send notification: ${response.body}");

        // Check for UNREGISTERED error
        final errorDetails = errorResponse['error']?['details'] as List?;
        if (errorDetails != null && errorDetails.isNotEmpty) {
          for (var detail in errorDetails) {
            if (detail['@type']?.toString().contains('FcmError') == true) {
              if (detail['errorCode'] == 'UNREGISTERED') {
                // Mark this token as invalid for future reference
                _invalidTokens.add(token);

                return {
                  'success': false,
                  'error': 'UNREGISTERED',
                  'message': 'FCM token is no longer valid',
                };
              }
            }
          }
        }

        return {
          'success': false,
          'error': 'SEND_FAILED',
          'message': errorResponse['error']?['message'] ?? 'Unknown error',
          'statusCode': response.statusCode,
        };
      }
    } catch (e, stack) {
      CrashlyticsService.recordError(e, stack);
      debugPrint("❌ Exception sending notification: $e");
      return {'success': false, 'error': 'EXCEPTION', 'message': e.toString()};
    }
  }

  // Method to clear invalid tokens (useful for testing)
  static void clearInvalidTokens() {
    _invalidTokens.clear();
  }

  // Method to check if a token is valid
  static bool isTokenValid(String token) {
    return token.isNotEmpty && !_invalidTokens.contains(token);
  }

  static Future<Map<String, dynamic>> sendMessageNotification(
    String token, {
    required String chatId,
    required String messageId,
    required String senderId,
    required String title,
    required String body,
    required String createdAt,
    bool isDeleted = false,
  }) async {
    final String encryptionKey = dotenv.maybeGet("ENCRYPTION_KEY") ?? "";
    final Map<String, dynamic> message = {
      "chatId": chatId,
      "messageId": messageId,
      "senderId": senderId,
      "title": title,
      "body": body,
      "createdAt": createdAt,
      "isDeleted": isDeleted,
    };
    final String encryptedMessage = EncryptionHelper.encryptObject(
      message,
      encryptionKey,
    );
    return sendNotification(token: token, data: {"msgData": encryptedMessage});
  }
}
