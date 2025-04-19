import 'dart:async';

import 'package:chatapp/core/helpers/encryption_helper.dart';
import 'package:chatapp/core/strings/firebase_collections.dart';
import 'package:chatapp/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class CustomNotificationService {
  static final _localNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static NotificationResponse? globalNotificationResponse;
  static final StreamController<NotificationResponse>
  _globalNotificationResponseStream =
      StreamController<NotificationResponse>.broadcast();
  static Stream<NotificationResponse> get globalNotificationResponseStream =>
      _globalNotificationResponseStream.stream;
  static final _firestore = FirebaseFirestore.instance;
  static const String _channelId = "high_importance_channel";
  static const String _channelName = "Chat Messages";

  static bool get isAuthentication => FirebaseAuth.instance.currentUser != null;

  static initialization() async {
    // step 1 initialize firebase
    if (Firebase.apps.isEmpty) Firebase.initializeApp();

    // step 2 request permissions
    final isPermissionAllowed = await requestPermissions();
    if (!isPermissionAllowed) return;

    // step 3 initialize local notifications
    await initializeLocalNotifications();

    // step 4 create notification channel
    await createNotificationChannel();

    // step 5 setup message handler
    if (isAuthentication) {
      await setupMessagesHandlers();
    }
  }

  static Future<bool> requestPermissions() async {
    try {
      final res =
          await _localNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >()
              ?.requestNotificationsPermission();

      if (res == false) return false;

      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      return settings.authorizationStatus == AuthorizationStatus.authorized;
    } catch (e) {
      debugPrint("error for request notifications permissions: $e");
      return false;
    }
  }

  static Future<void> initializeLocalNotifications() async {
    try {
      // initial for android
      const androidSettings = AndroidInitializationSettings(
        "@mipmap/ic_launcher",
      );

      // initial for ios
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // initial settings
      const initializationSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // initial local notifications
      await _localNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: onDidReceiveNResponse,
        onDidReceiveBackgroundNotificationResponse: onDidReceiveNResponse,
      );
    } catch (e) {
      debugPrint("error for initial local notifications: $e");
    }
  }

  static void onDidReceiveNResponse(NotificationResponse details) {
    globalNotificationResponse = details;
    _globalNotificationResponseStream.add(details);
    debugPrint("Notification clicked: ${details.payload}");
  }

  static Future<void> createNotificationChannel() async {
    try {
      final androidChannel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        importance: Importance.max,
        showBadge: true,
        enableVibration: true,
      );

      await _localNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(androidChannel);
    } catch (e) {
      debugPrint("error for create notification channel: $e");
    }
  }

  static setupMessagesHandlers() {
    FirebaseMessaging.onMessage.listen(onMessageHandler);
    FirebaseMessaging.onMessageOpenedApp.listen(onMessageOpenedAppHandler);
  }

  static void onMessageHandler(RemoteMessage event) {
    // message notification
    // if (event.data.containsKey("msgData")) {
    //   showChatMessageNotification(event.data["msgData"]);
    // }
    // other types...
  }

  static void onMessageOpenedAppHandler(RemoteMessage event) {
    // message notification
    if (event.data.containsKey("msgData")) {
      showChatMessageNotification(event.data["msgData"]);
    }
    // other types...
  }

  static void onMessageBackgroundHandler(RemoteMessage event) async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // message notification
    if (event.data.containsKey("msgData")) {
      showChatMessageNotification(event.data["msgData"]);
    }
    // other types...
  }

  static Future<void> setChatMessageReceived(
    String chatId,
    String messageId,
  ) async {
    try {
      // Skip if either ID is empty
      if (chatId.isEmpty || messageId.isEmpty) return;

      final chatRef = _firestore
          .collection(FirebaseCollections.chats)
          .doc(chatId);

      final messagesRef = chatRef
          .collection(FirebaseCollections.messages)
          .doc(messageId);

      // Use transaction for better atomicity
      await _firestore.runTransaction((transaction) async {
        // Update message document
        transaction.update(messagesRef, {'isReceived': true});

        // Update chat document's last message
        transaction.set(chatRef, {
          'lastMessage': {'isReceived': true},
        }, SetOptions(merge: true));
      });
    } catch (e, stack) {
      debugPrint('Error marking messages as received: $e');
    }
  }

  static void showChatMessageNotification(String encryptedData) async {
    await dotenv.load(fileName: ".env");
    final data = EncryptionHelper.decryptToMap(
      encryptedData,
      dotenv.maybeGet("ENCRYPTION_KEY") ?? "",
    );
    final String chatId = data['chatId'];
    final String messageId = data['messageId'];
    final String senderId = data['senderId'];
    final String title = data['senderId'];
    final String body = data['body'];
    final bool isDeleted = data['isDeleted'];
    final DateTime timestamp = DateTime.parse(data['createdAt']);

    await setChatMessageReceived(chatId, messageId);

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails(
        chatId: chatId,
        senderId: senderId,
        title: title,
        body:
            isDeleted
                ? PlatformDispatcher.instance.locale.languageCode == 'ar'
                    ? "تم حذف الرسالة!"
                    : "Deleted Message"
                : body,
        timestamp: timestamp,
      ),
      iOS: darwinNotificationDetails(chatId),
    );

    await _localNotificationsPlugin.show(
      chatId.hashCode,
      title,
      body,
      notificationDetails,
      payload: chatId,
    );
  }

  static AndroidNotificationDetails androidNotificationDetails({
    required String chatId,
    required String senderId,
    required String title,
    required String body,
    required DateTime timestamp,
  }) {
    final person = Person(name: title, key: senderId);
    final messagingStyle = MessagingStyleInformation(
      person,
      messages: [Message(body, timestamp, person)],
      groupConversation: false,
    );
    return AndroidNotificationDetails(
      _channelId,
      _channelName,
      importance: Importance.max,
      priority: Priority.max,
      styleInformation: messagingStyle,
      when: timestamp.microsecondsSinceEpoch,
    );
  }

  static DarwinNotificationDetails darwinNotificationDetails(String chatId) {
    return DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      badgeNumber: 1,
      threadIdentifier: chatId,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );
  }

  static void cancelNotifications(String chatId) async {
    try {
      await _localNotificationsPlugin.cancel(chatId.hashCode);
    } catch (e) {
      debugPrint("error for cancel notification: $e");
    }
  }

  static Future<String?> getFCMToken() async {
    return await _messaging.getToken();
  }
}
