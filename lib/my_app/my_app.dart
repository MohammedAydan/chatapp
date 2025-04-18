import 'package:chatapp/core/l10n/app_localizations.dart';
import 'package:chatapp/di/injection_container.dart';
import 'package:chatapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chatapp/global/blocs/locale/locale_bloc.dart';
import 'package:chatapp/global/blocs/network/network_bloc.dart';
import 'package:chatapp/global/blocs/theme/theme_bloc.dart';
import 'package:chatapp/routes/routes.dart';
import 'package:chatapp/routes/routes_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: _buildBlocProviders(),
      child: AppThemeWrapper(),
    );
  }

  // Separated provider initialization for better readability and maintainability
  List<BlocProvider> _buildBlocProviders() => [
    BlocProvider<LocaleBloc>(
      create: (_) => sl<LocaleBloc>()..add(LoadLocaleEvent()),
    ),
    BlocProvider<ThemeBloc>(
      create: (_) => sl<ThemeBloc>()..add(GetThemeModeEvent()),
    ),
    BlocProvider<NetworkBloc>(
      create: (_) => sl<NetworkBloc>()..add(CheckNetworkEvent()),
    ),
    BlocProvider<AuthBloc>(
      create: (_) => sl<AuthBloc>()..add(CheckIsAuthEvent()),
    ),
  ];
}

// Extracted theme wrapper to isolate theme-related logic
class AppThemeWrapper extends StatelessWidget {
  const AppThemeWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleBloc, LocaleState>(
      builder: (context, localeState) {
        if (localeState is LocaleLoadedState) {
          return BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, state) {
              final themeMode = _getThemeMode(state);

              if (state is LoadedThemeModeState) {
                SystemChrome.setSystemUIOverlayStyle(
                  SystemUiOverlayStyle(
                    statusBarBrightness:
                        themeMode == ThemeMode.dark
                            ? Brightness.dark
                            : Brightness.light,
                    statusBarColor: Colors.transparent,
                    statusBarIconBrightness: Theme.of(context).brightness,
                    systemNavigationBarIconBrightness:
                        Theme.of(context).brightness,
                  ),
                );
                return MaterialApp(
                  supportedLocales: AppLocalizations.supportedLocales,
                  localizationsDelegates:
                      AppLocalizations.localizationsDelegates,
                  debugShowCheckedModeBanner: false,
                  locale: localeState.locale,
                  title: 'Chats App',
                  themeMode: themeMode,
                  theme: _buildLightTheme(),
                  darkTheme: _buildDarkTheme(),
                  initialRoute: RoutesPaths.splash,
                  routes: routes,
                  builder:
                      (context, child) => NetworkStatusHandler(child: child),
                );
              }

              return SizedBox();
            },
          );
        }
        return SizedBox();
      },
    );
  }

  // Determine theme mode based on state
  ThemeMode _getThemeMode(ThemeState state) =>
      state is LoadedThemeModeState ? state.themeMode : ThemeMode.system;

  // Optimized light theme configuration
  ThemeData _buildLightTheme() => ThemeData.light(useMaterial3: true).copyWith(
    scaffoldBackgroundColor: Colors.white,
    brightness: Brightness.light,
    // Add more theme optimizations if needed
    appBarTheme: const AppBarTheme(elevation: 0, backgroundColor: Colors.white),
    primaryColor: const Color(0xff6200ee),
  );

  // Optimized dark theme configuration
  ThemeData _buildDarkTheme() => ThemeData.dark(useMaterial3: true).copyWith(
    scaffoldBackgroundColor: Colors.black,
    brightness: Brightness.dark,
    // Add more theme optimizations if needed
    appBarTheme: const AppBarTheme(elevation: 0, backgroundColor: Colors.black),
  );
}

// Extracted network status handler for better separation of concerns
class NetworkStatusHandler extends StatelessWidget {
  final Widget? child;

  const NetworkStatusHandler({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<NetworkBloc, NetworkState>(
      listener: (context, state) {
        if (state is OfflineState) {
          _showOfflineSnackBar(context);
        }
      },
      child: child ?? const SizedBox.shrink(),
    );
  }

  // Centralized snackbar logic with debouncing
  void _showOfflineSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No Internet Connection'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
