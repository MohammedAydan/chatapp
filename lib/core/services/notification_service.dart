// import 'dart:async';
// import 'dart:io';
// import 'dart:typed_data';

// import 'package:chatapp/core/services/call_kit_config.dart';
// import 'package:chatapp/core/services/crashlytics_service.dart';
// import 'package:chatapp/core/services/jitsi_service.dart';
// import 'package:chatapp/core/strings/actions_type.dart';
// import 'package:chatapp/core/strings/firebase_collections.dart';
// import 'package:chatapp/features/home/data/models/chat_message_model.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_callkit_incoming/entities/entities.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// /// A service class that handles all notification-related functionality
// /// including FCM setup, permissions, and display of local notifications.
// class NotificationService {
//   // Private constructor to prevent instantiation
//   NotificationService._();

//   // Core services
//   static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
//   static final FlutterLocalNotificationsPlugin _localNotifications =
//       FlutterLocalNotificationsPlugin();
//   static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   static final StreamController<NotificationResponse> _responseController =
//       StreamController.broadcast();

//   // Streams
//   static Stream<NotificationResponse> get notificationResponseStream =>
//       _responseController.stream;

//   // Configuration constants
//   static const String _channelId = 'high_importance_channel';
//   static const String _channelName = 'Chat Messages';
//   static const String _channelDescription =
//       'This channel is used for chat notifications';
//   static const String _notificationSound = 'notification';

//   // Call notification constants
//   static const int _callTimeoutDuration = 30000; // 30 seconds ring duration
//   static const int _videoCallType = 0;

//   // Initialization state
//   static bool _isInitialized = false;

//   // Cache for active notifications to reduce database calls
//   static final Map<String, ChatMessageModel> _messageCache = {};

//   // Set to track processed message IDs to prevent duplicates
//   static final Set<String> _processedMessageIds = {};

//   // Active call tracking to prevent multiple call instances
//   static String? _activeCallRoomId;
//   static JitsiService? _activeJitsiService;

//   // Auth status check
//   static bool get isUserSignedIn => FirebaseAuth.instance.currentUser != null;

//   // Check if notifications should be shown
//   static bool shouldShowNotifications() => isUserSignedIn;

//   /// Initializes the notification service
//   /// Returns true if initialization was successful
//   static Future<bool> initialize() async {
//     if (_isInitialized) return true;

//     try {
//       // Initialize Firebase first if not already initialized
//       if (Firebase.apps.isEmpty) {
//         await Firebase.initializeApp();
//       }

//       // Setup components in sequence
//       await _requestPermissions();
//       await _initializeLocalNotifications();
//       await _createNotificationChannel();
//       await _setupMessageHandlers();

//       _isInitialized = true;
//       debugPrint('NotificationService initialized successfully');
//       return true;
//     } catch (e, stack) {
//       CrashlyticsService.recordError(e, stack);
//       debugPrint('Failed to initialize NotificationService: $e');
//       return false;
//     }
//   }

//   /// Simplified initialization for background processing
//   static Future<bool> initializeForBackground() async {
//     try {
//       if (_isInitialized) return true;

//       // Only initialize what's needed for notifications
//       await _initializeLocalNotifications();
//       await _createNotificationChannel();

//       _isInitialized = true;
//       return true;
//     } catch (e, stack) {
//       CrashlyticsService.recordError(e, stack);
//       debugPrint('Failed to initialize NotificationService for background: $e');
//       return false;
//     }
//   }

//   /// Request notification permissions based on platform
//   static Future<void> _requestPermissions() async {
//     try {
//       final settings = await _messaging.requestPermission(
//         alert: true,
//         badge: true,
//         sound: true,
//         provisional: false,
//       );

//       debugPrint(
//         'App notification permission status: ${settings.authorizationStatus}',
//       );
//     } catch (e, stack) {
//       CrashlyticsService.recordError(e, stack);
//       debugPrint('Error requesting permissions: $e');
//     }
//   }

//   /// Initialize local notifications plugin
//   static Future<void> _initializeLocalNotifications() async {
//     try {
//       const AndroidInitializationSettings androidSettings =
//           AndroidInitializationSettings('@mipmap/ic_launcher');

//       const DarwinInitializationSettings iosSettings =
//           DarwinInitializationSettings(
//             requestAlertPermission: true,
//             requestBadgePermission: true,
//             requestSoundPermission: true,
//           );

//       const InitializationSettings initSettings = InitializationSettings(
//         android: androidSettings,
//         iOS: iosSettings,
//       );

//       await _localNotifications.initialize(
//         initSettings,
//         onDidReceiveNotificationResponse: _handleNotificationResponse,
//       );
//     } catch (e, stack) {
//       CrashlyticsService.recordError(e, stack);
//       debugPrint('Error initializing local notifications: $e');
//     }
//   }

//   /// Create notification channel for Android
//   static Future<void> _createNotificationChannel() async {
//     try {
//       if (Platform.isAndroid) {
//         final AndroidNotificationChannel channel = AndroidNotificationChannel(
//           _channelId,
//           _channelName,
//           description: _channelDescription,
//           importance: Importance.max,
//           enableVibration: true,
//           vibrationPattern: Int64List.fromList([0, 500, 1000, 500]),
//           ledColor: Colors.green,
//           showBadge: true,
//         );

//         await _localNotifications
//             .resolvePlatformSpecificImplementation<
//               AndroidFlutterLocalNotificationsPlugin
//             >()
//             ?.createNotificationChannel(channel);
//       }
//     } catch (e, stack) {
//       CrashlyticsService.recordError(e, stack);
//       debugPrint('Error creating notification channel: $e');
//     }
//   }

//   /// Setup all message handlers for different app states
//   static Future<void> _setupMessageHandlers() async {
//     try {
//       // Foreground message handler
//       FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

//       // Background/terminated app opened from notification
//       FirebaseMessaging.onMessageOpenedApp.listen((message) async {
//         if (message.data.containsKey('room')) {
//           await _handleCallNotificationData(message.data);
//           return;
//         }
//         _handleChatMessage(message, fromBackground: true);
//       });

//       // App opened from terminated state via notification
//       final initialMessage = await _messaging.getInitialMessage();
//       if (initialMessage != null) {
//         _handleChatMessage(initialMessage, fromBackground: true);
//       }
//     } catch (e, stack) {
//       CrashlyticsService.recordError(e, stack);
//       debugPrint('Error setting up message handlers: $e');
//     }
//   }

//   /// Get notification launch details
//   static Future<NotificationAppLaunchDetails?>
//   getNotificationLaunchDetails() async {
//     return _localNotifications.getNotificationAppLaunchDetails();
//   }

//   /// Handle foreground messages
//   static void _handleForegroundMessage(RemoteMessage message) async {
//     // Skip processing if user is signed out
//     if (!shouldShowNotifications()) return;

//     if (message.data.containsKey('room')) {
//       await _handleCallNotificationData(message.data);
//       return;
//     }

//     // Process chat message
//     _handleChatMessage(message);
//   }

//   /// Handle chat message notifications
//   static Future<void> _handleChatMessage(
//     RemoteMessage message, {
//     bool fromBackground = false,
//   }) async {
//     try {
//       // Skip processing if user is signed out
//       if (!shouldShowNotifications()) return;

//       if (message.data.isEmpty) return;

//       // Process message data
//       if (message.data.containsKey('chatId') &&
//           message.data.containsKey('messageId') &&
//           message.data.containsKey('action')) {
//         final String messageId = message.data['messageId'];

//         // Skip if we've already processed this message
//         if (_processedMessageIds.contains(messageId)) return;
//         _processedMessageIds.add(messageId);

//         final String chatId = message.data['chatId'];
//         final String action = message.data['action'];

//         if (action == ActionsType.addMessage) {
//           await setChatMessagesReceived(chatId, messageId);
//           await showNotificationFromData(message.data);
//         }

//         // Navigate if from background tap
//         if (fromBackground) {
//           _navigateToChat(chatId);
//         }
//       }
//     } catch (e, stack) {
//       CrashlyticsService.recordError(e, stack);
//       debugPrint('Error handling chat message: $e');
//     }
//   }

//   /// Handle notification tap
//   static void _handleNotificationResponse(NotificationResponse response) {
//     try {
//       _responseController.add(response);

//       // Navigate to chat if payload exists
//       if (response.payload != null && response.payload!.isNotEmpty) {
//         _navigateToChat(response.payload!);
//       }
//     } catch (e, stack) {
//       CrashlyticsService.recordError(e, stack);
//       debugPrint('Error handling notification response: $e');
//     }
//   }

//   /// Navigate to chat screen (to be completed with navigation logic)
//   static void _navigateToChat(String chatId) {
//     // This would be implemented with your navigation system
//     debugPrint('Navigation requested to chat: $chatId');

//     // Example (uncomment and modify as needed):
//     // final navigationService = GetIt.instance<NavigationService>();
//     // navigationService.navigateTo(Routes.chatScreen, arguments: ChatScreenArgs(chatId: chatId));
//   }

//   /// Show a custom notification with chat message details
//   static Future<void> showNotificationFromData(
//     Map<String, dynamic> messageData,
//   ) async {
//     try {
//       // Skip processing if user is signed out
//       if (!shouldShowNotifications()) return;

//       // Handle call notifications
//       if (messageData.containsKey('type') && messageData.containsKey('room')) {
//         await _handleCallNotificationData(messageData);
//         return;
//       }

//       // Validate required data for chat messages
//       if (!messageData.containsKey('chatId') ||
//           !messageData.containsKey('messageId')) {
//         debugPrint('Missing required notification data');
//         return;
//       }

//       // Fetch message details
//       final String chatId = messageData['chatId'];
//       final String messageId = messageData['messageId'];
//       final String action = messageData['action'] ?? '';

//       // Try to get message from cache first
//       ChatMessageModel? message = _messageCache[messageId];

//       if (message == null) {
//         // Fetch from database if not in cache
//         try {
//           final messageDoc =
//               await _firestore
//                   .collection(FirebaseCollections.chats)
//                   .doc(chatId)
//                   .collection(FirebaseCollections.messages)
//                   .doc(messageId)
//                   .get();

//           if (!messageDoc.exists || messageDoc.data() == null) {
//             debugPrint('Message document not found');
//             return;
//           }

//           // Create notification from message data
//           message = ChatMessageModel.fromJson(messageDoc.data()!);

//           // Cache the message
//           _messageCache[messageId] = message;
//         } catch (e, stack) {
//           CrashlyticsService.recordError(e, stack);
//           debugPrint('Error fetching message data: $e');
//           return;
//         }
//       }

//       // Mark as received first to ensure database consistency
//       await setChatMessagesReceived(chatId, messageId);

//       // Display the notification
//       await _displayChatNotification(message, chatId, action);
//     } catch (e, stack) {
//       CrashlyticsService.recordError(e, stack);
//       debugPrint('Error showing notification: $e');
//     }
//   }

//   /// Display chat notification with platform-specific settings
//   static Future<void> _displayChatNotification(
//     ChatMessageModel message,
//     String chatId,
//     String action,
//   ) async {
//     try {
//       final String title = message.senderId;
//       String body = message.message;

//       // Handle deleted messages
//       if (action == ActionsType.deletedMessage) {
//         body = "Deleted Message";
//       }

//       final DateTime timestamp = DateTime.parse(message.createdAt).toLocal();

//       // Create person for messaging style
//       final person = Person(name: title, key: message.senderId);

//       // Platform-specific notification details
//       final androidDetails = _buildAndroidNotificationDetails(
//         person: person,
//         title: title,
//         body: body,
//         timestamp: timestamp,
//         chatId: chatId,
//       );

//       final iosDetails = _buildIOSNotificationDetails(chatId);

//       final notificationDetails = NotificationDetails(
//         android: androidDetails,
//         iOS: iosDetails,
//       );

//       // Show the notification
//       final notificationId = chatId.hashCode; // Prevent overflow
//       await _localNotifications.show(
//         notificationId,
//         title,
//         body,
//         notificationDetails,
//         payload: chatId,
//       );

//       // Update summary for grouping
//       await _updateSummaryNotification(chatId, title);
//     } catch (e, stack) {
//       CrashlyticsService.recordError(e, stack);
//       debugPrint('Error displaying chat notification: $e');
//     }
//   }

//   /// Handle call notification data
//   static Future<void> _handleCallNotificationData(
//     Map<String, dynamic> messageData,
//   ) async {
//     try {
//       // Skip if user not signed in
//       if (!shouldShowNotifications()) return;

//       // Validate required call data
//       if (!_validateCallData(messageData)) {
//         debugPrint('Invalid call data: $messageData');
//         return;
//       }

//       // Don't allow new calls if there's already an active call
//       if (_activeCallRoomId != null &&
//           _activeCallRoomId == messageData['room']) {
//         debugPrint('Already handling call for room: ${messageData['room']}');
//         return;
//       }

//       await _showCallNotification(messageData);
//     } catch (e, stack) {
//       CrashlyticsService.recordError(e, stack);
//       debugPrint('Error handling call notification data: $e');
//     }
//   }

//   /// Validate call data contains required fields
//   static bool _validateCallData(Map<String, dynamic> messageData) {
//     return messageData.containsKey('room') &&
//         messageData.containsKey('displayName') &&
//         messageData.containsKey('email');
//   }

//   /// Show an incoming call notification
//   static Future<void> _showCallNotification(
//     Map<String, dynamic> messageData,
//   ) async {
//     try {
//       final String roomId = messageData['room'];
//       final String displayName = messageData['displayName'] ?? 'Unknown Caller';
//       final String avatar = messageData['avatar'] ?? '';
//       final String email = messageData['email'];

//       // Set as active call
//       _activeCallRoomId = roomId;

//       // Initialize Jitsi service with safe parameters
//       _activeJitsiService = JitsiService(
//         room: roomId,
//         displayName: displayName,
//         avatar: avatar,
//         email: email,
//       );

//       // Configure call notification
//       final CallKitConfig callKitConfig = CallKitConfig(
//         nameCaller: displayName,
//         appName: 'Chatapp',
//         avatar: avatar,
//         handler: email,
//         type: _videoCallType,
//         textAccept: "Accept",
//         textDecline: "Decline",
//         missedCallNotification: NotificationParams(
//           showNotification: true,
//           isShowCallback: true,
//           subtitle: 'Missed video call',
//           callbackText: 'Call back',
//         ),
//         callingNotification: const NotificationParams(
//           showNotification: true,
//           isShowCallback: true,
//           subtitle: 'Incoming video call...',
//           callbackText: 'End Call',
//         ),
//         duration: _callTimeoutDuration,
//         extra: messageData,
//         headers: <String, dynamic>{
//           'platform': _getPlatformData(),
//           'timestamp': DateTime.now().toIso8601String(),
//         },
//       );

//       print("========-Step one for a Join success");
//       // Show incoming call UI
//       await callKitConfig.showIncomingCall(roomId: roomId);
//       print("========-Joined To Room Successfully");

//       // Handle call events with improved error handling
//       // callKitConfig.onEvent().listen(
//       //   (event) => _handleCallEvent(event, roomId),
//       //   onError: (error, stack) {
//       //     CrashlyticsService.recordError(error, stack);
//       //     debugPrint('Error in call event stream: $error');
//       //     _resetActiveCall();
//       //   },
//       //   cancelOnError: false,
//       // );
//     } catch (e, stack) {
//       CrashlyticsService.recordError(e, stack);
//       debugPrint('Error showing call notification: $e');
//       _resetActiveCall();
//     }
//   }

//   /// Handle call events with improved error handling
//   static Future<void> _handleCallEvent(CallEvent? event, String roomId) async {
//     if (event == null) return;
//     // print("=---------------------------------------------------------------=");
//     // print(event.event);
//     // print(event.body);
//     // print("=---------------------------------------------------------------=");

//     try {
//       switch (event.event) {
//         case Event.actionCallIncoming:
//           debugPrint('Incoming call received');
//           break;

//         case Event.actionCallStart:
//           debugPrint('Call started');
//           break;

//         case Event.actionCallAccept:
//           print("========-Joined To Room Successfully: Call accepted");
//           debugPrint('Call accepted');
//           await _safeJoinMeeting();
//           break;

//         case Event.actionCallDecline:
//           print("========-Joined To Room Successfully: Call declined");
//           debugPrint('Call declined');
//           await _safeCloseMeeting();
//           _resetActiveCall();
//           break;

//         case Event.actionCallEnded:
//           debugPrint('Call ended');
//           await _safeCloseMeeting();
//           _resetActiveCall();
//           break;

//         case Event.actionCallTimeout:
//           debugPrint('Call timed out');
//           await _safeCloseMeeting();
//           _resetActiveCall();
//           break;

//         case Event.actionCallCallback:
//           if (Platform.isAndroid) {
//             debugPrint('Call back requested');
//             // Implement callback logic
//           }
//           break;

//         case Event.actionCallToggleHold:
//         case Event.actionCallToggleMute:
//         case Event.actionCallToggleDmtf:
//         case Event.actionCallToggleGroup:
//         case Event.actionCallToggleAudioSession:
//         case Event.actionDidUpdateDevicePushTokenVoip:
//           if (Platform.isIOS) {
//             debugPrint('iOS specific action: ${event.event}');
//             // Handle iOS specific actions
//           }
//           break;

//         case Event.actionCallCustom:
//           debugPrint('Custom call action received');
//           // Handle custom actions
//           break;
//       }
//     } catch (e, stack) {
//       CrashlyticsService.recordError(e, stack);
//       debugPrint('Error handling call event: $e');
//       _resetActiveCall();
//     }
//   }

//   /// Reset active call data
//   static void _resetActiveCall() {
//     _activeCallRoomId = null;
//     _activeJitsiService = null;
//   }

//   /// Safely join a meeting with improved error handling
//   static Future<void> _safeJoinMeeting() async {
//     if (_activeJitsiService == null) {
//       debugPrint('No active Jitsi service to join meeting');
//       return;
//     }

//     try {
//       print("========-STEP -1 - Joined To Room");
//       await _activeJitsiService!.joinMeeting();
//       print("========-STEP -2 - Joined To Room");
//     } catch (e, stack) {
//       print("========-ERROR - Failed to join room: $e");
//       CrashlyticsService.recordError(e, stack);
//       debugPrint('Error joining meeting: $e');

//       // Check if error is related to URL formatting
//       if (e.toString().contains('MalformedURLException')) {
//         debugPrint(
//           'URL malformation detected, attempting fallback with explicit URL',
//         );
//       } else {
//         // Try general fallback method
//         try {
//           await _fallbackJoinMeeting();
//         } catch (fallbackError, fallbackStack) {
//           CrashlyticsService.recordError(fallbackError, fallbackStack);
//           debugPrint('Fallback join also failed: $fallbackError');
//         }
//       }
//     }
//   }

//   /// Fallback method to join meeting if primary method fails
//   static Future<void> _fallbackJoinMeeting() async {
//     if (_activeJitsiService == null) return;

//     // Implement alternative joining strategy here
//     // This could be a different approach to initialize Jitsi
//     debugPrint('Attempting fallback join strategy');
//     await _activeJitsiService!.joinMeeting();
//   }

//   /// Safely close a meeting with error handling
//   static Future<void> _safeCloseMeeting() async {
//     if (_activeJitsiService == null) {
//       debugPrint('No active Jitsi service to close meeting');
//       return;
//     }

//     try {
//       await _activeJitsiService!.closeMeeting();
//     } catch (e, stack) {
//       CrashlyticsService.recordError(e, stack);
//       debugPrint('Error closing meeting: $e');
//     }
//   }

//   /// Get platform information
//   static String _getPlatformData() {
//     return Platform.operatingSystem;
//   }

//   /// Build Android notification details with styling
//   static AndroidNotificationDetails _buildAndroidNotificationDetails({
//     required Person person,
//     required String title,
//     required String body,
//     required DateTime timestamp,
//     required String chatId,
//   }) {
//     final messagingStyle = MessagingStyleInformation(
//       person,
//       messages: [Message(body, timestamp, person)],
//       groupConversation: false,
//     );

//     return AndroidNotificationDetails(
//       _channelId,
//       _channelName,
//       channelDescription: _channelDescription,
//       importance: Importance.max,
//       priority: Priority.high,
//       styleInformation: messagingStyle,
//       ledOnMs: 1000,
//       ledOffMs: 500,
//       enableVibration: true,
//       vibrationPattern: Int64List.fromList([0, 500, 1000, 500]),
//       groupKey: chatId,
//       setAsGroupSummary: false, // Individual messages aren't summaries
//       autoCancel: true,
//       showWhen: true,
//       when: timestamp.millisecondsSinceEpoch,
//     );
//   }

//   /// Build iOS notification details
//   static DarwinNotificationDetails _buildIOSNotificationDetails(String chatId) {
//     return DarwinNotificationDetails(
//       presentAlert: true,
//       presentBadge: true,
//       presentSound: true,
//       badgeNumber: 1,
//       threadIdentifier: chatId,
//       interruptionLevel: InterruptionLevel.timeSensitive,
//     );
//   }

//   /// Update summary notification for grouped messages
//   static Future<void> _updateSummaryNotification(
//     String chatId,
//     String title,
//   ) async {
//     try {
//       // Only needed for Android
//       if (!Platform.isAndroid) return;

//       final activeNotifications =
//           await _localNotifications.getActiveNotifications();

//       final chatNotifications =
//           activeNotifications
//               .where((notification) => notification.payload == chatId)
//               .toList();

//       // Only create summary if we have multiple notifications for this chat
//       if (chatNotifications.length > 1) {
//         final List<String> lines =
//             chatNotifications
//                 .map(
//                   (notification) =>
//                       '${notification.title}: ${notification.body}',
//                 )
//                 .take(5)
//                 .toList();

//         final inboxStyle = InboxStyleInformation(
//           lines,
//           contentTitle: '$title (${chatNotifications.length})',
//           summaryText: '${chatNotifications.length} new messages',
//         );

//         final androidDetails = AndroidNotificationDetails(
//           _channelId,
//           _channelName,
//           channelDescription: _channelDescription,
//           importance: Importance.max,
//           priority: Priority.high,
//           styleInformation: inboxStyle,
//           groupKey: chatId,
//           setAsGroupSummary: true, // This is the summary notification
//         );

//         final summaryDetails = NotificationDetails(android: androidDetails);

//         // Use a fixed ID for summary notifications for this chat
//         final summaryId =
//             chatId.hashCode * 10 +
//             1; // Ensure unique ID from regular notifications
//         await _localNotifications.show(
//           summaryId,
//           '$title (${chatNotifications.length})',
//           '${chatNotifications.length} new messages',
//           summaryDetails,
//           payload: chatId,
//         );
//       }
//     } catch (e, stack) {
//       CrashlyticsService.recordError(e, stack);
//       debugPrint('Error updating summary notification: $e');
//     }
//   }

//   /// Dismiss all notifications
//   static Future<bool> dismissAllNotifications() async {
//     try {
//       await _localNotifications.cancelAll();
//       return true;
//     } catch (e, stack) {
//       CrashlyticsService.recordError(e, stack);
//       debugPrint('Error dismissing all notifications: $e');
//       return false;
//     }
//   }

//   /// Dismiss a specific notification by ID
//   static Future<bool> dismissNotification(int id) async {
//     try {
//       await _localNotifications.cancel(id);
//       return true;
//     } catch (e, stack) {
//       CrashlyticsService.recordError(e, stack);
//       debugPrint('Error dismissing notification: $e');
//       return false;
//     }
//   }

//   /// Dismiss notifications for a specific chat
//   static Future<bool> dismissChatNotifications(String chatId) async {
//     try {
//       // Calculate IDs based on chat ID
//       final regularId = chatId.hashCode;
//       final summaryId = regularId * 10 + 1;

//       // Cancel all related notifications
//       await _localNotifications.cancel(regularId);
//       await _localNotifications.cancel(summaryId);
//       await _localNotifications.cancel(regularId, tag: chatId);

//       return true;
//     } catch (e, stack) {
//       CrashlyticsService.recordError(e, stack);
//       debugPrint('Error dismissing chat notifications: $e');
//       return false;
//     }
//   }

//   /// Mark message as received in Firestore
//   static Future<void> setChatMessagesReceived(
//     String chatId,
//     String messageId,
//   ) async {
//     try {
//       // Skip if either ID is empty
//       if (chatId.isEmpty || messageId.isEmpty) return;

//       final chatRef = _firestore
//           .collection(FirebaseCollections.chats)
//           .doc(chatId);

//       final messagesRef = chatRef
//           .collection(FirebaseCollections.messages)
//           .doc(messageId);

//       // Use transaction for better atomicity
//       await _firestore.runTransaction((transaction) async {
//         // Update message document
//         transaction.update(messagesRef, {'isReceived': true});

//         // Update chat document's last message
//         transaction.set(chatRef, {
//           'lastMessage': {'isReceived': true},
//         }, SetOptions(merge: true));
//       });
//     } catch (e, stack) {
//       CrashlyticsService.recordError(e, stack);
//       debugPrint('Error marking messages as received: $e');
//     }
//   }

//   /// Get the current FCM token
//   static Future<String?> getFcmToken() async {
//     try {
//       return await _messaging.getToken();
//     } catch (e, stack) {
//       CrashlyticsService.recordError(e, stack);
//       debugPrint('Error getting FCM token: $e');
//       return null;
//     }
//   }

//   /// Listen for token refreshes
//   static Stream<String> onRefreshFcmToken() {
//     return _messaging.onTokenRefresh;
//   }

//   /// Clear message cache to free memory
//   static void clearMessageCache() {
//     _messageCache.clear();
//   }

//   /// Clear processed message IDs to prevent memory leaks
//   static void clearProcessedMessageIds() {
//     if (_processedMessageIds.length > 1000) {
//       // Keep the most recent 100 IDs to prevent complete loss of tracking
//       final recentIds = _processedMessageIds.toList().sublist(
//         _processedMessageIds.length - 100,
//       );
//       _processedMessageIds.clear();
//       _processedMessageIds.addAll(recentIds);
//     }
//   }

//   /// Perform periodic cleanup to prevent memory leaks
//   static void performPeriodicCleanup() {
//     clearProcessedMessageIds();

//     // Only keep recent messages in cache
//     if (_messageCache.length > 100) {
//       final cachedIds = _messageCache.keys.toList();
//       final toRemove = cachedIds.sublist(0, cachedIds.length - 50);
//       for (final id in toRemove) {
//         _messageCache.remove(id);
//       }
//     }
//   }

//   /// Dispose resources when no longer needed
//   static void dispose() {
//     _responseController.close();
//     clearMessageCache();
//     clearProcessedMessageIds();
//     _resetActiveCall();
//   }
// }
