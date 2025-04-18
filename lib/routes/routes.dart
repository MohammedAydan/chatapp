import 'package:chatapp/features/auth/presentation/pages/sign_in_page.dart';
import 'package:chatapp/features/auth/presentation/pages/splash_page.dart';
import 'package:chatapp/features/home/presentation/pages/home_page.dart';
import 'package:chatapp/features/settings/presentation/pages/settings_page.dart';
import 'package:chatapp/routes/routes_paths.dart';
import 'package:flutter/material.dart';

final Map<String, WidgetBuilder> routes = {
  RoutesPaths.splash: (context) => SplashPage(),
  RoutesPaths.signIn: (context) => SignInPage(),
  RoutesPaths.home: (context) => HomePage(),
  RoutesPaths.settings: (context) => SettingsPage(),
  // RoutesPaths.chat: (context) => ChatPage(),
};
