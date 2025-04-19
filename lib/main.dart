import 'dart:async';
import 'package:chatapp/core/services/crashlytics_service.dart';
import 'package:chatapp/core/services/custom_notification_service.dart';
import 'package:chatapp/di/injection_container.dart' as di;
import 'package:chatapp/firebase_options.dart';
import 'package:chatapp/my_app/my_app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

Future<void> main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await dotenv.load(fileName: ".env");
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      await di.init();

      // old code
      // await NotificationService.initialize();

      // new code
      await CustomNotificationService.initialization();

      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );
      await CrashlyticsService.initialize();

      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

      runApp(const MyApp());
    },
    (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack);
    },
  );
}

// new code
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  CustomNotificationService.onMessageBackgroundHandler(message);
}

// old code
// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   await NotificationService.initializeForBackground();

//   debugPrint('Handling background message: ${message.messageId}');
//   if (message.data.isNotEmpty) {
//     await NotificationService.showNotificationFromData(message.data);
//   }
// }
