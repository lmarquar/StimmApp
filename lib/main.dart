import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stimmapp/app/mobile/layout/init_app_layout.dart';
import 'package:stimmapp/app/mobile/pages/main/home/petitions/petition_detail_page.dart';
import 'package:stimmapp/app/mobile/pages/main/home/polls/poll_detail_page.dart';
import 'package:stimmapp/core/constants/constants.dart';
import 'package:stimmapp/core/notifiers/app_state_notifier.dart';
import 'package:stimmapp/core/notifiers/notifiers.dart';
import 'package:stimmapp/core/firebase/firebase_options.dart';
import 'package:stimmapp/core/errors/error_log_tool.dart';
import 'package:stimmapp/core/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:stimmapp/core/di/service_locator.dart';
import 'package:stimmapp/l10n/app_localizations.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    errorLogTool(
      exception: details.exception,
      errorCustomMessage: 'Flutter framework error',
    );
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    errorLogTool(exception: error, errorCustomMessage: 'Uncaught async error');
    return true;
  };

  SystemChrome.setPreferredOrientations(const [DeviceOrientation.portraitUp]);

  await Firebase.initializeApp(
    name: 'stimmapp-dev',
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Note: Only enable this for test builds
  if (!kIsWeb) {
    await FirebaseAuth.instance.setSettings(
      appVerificationDisabledForTesting: true,
    );
  }

  // Initialize service locator (Firestore, repositories, etc.)
  locator.init();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AppStateNotifier? appStateNotifier;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initAsync();
  }

  Future<void> _initAsync() async {
    // load persisted theme first
    await initThemeMode();
    // only create the composite notifier after persisted state is loaded to avoid immediate circular updates
    appStateNotifier = AppStateNotifier(
      isDarkModeNotifier.value,
      appLocale.value,
    );
    setState(() {
      _initialized = true;
    });
  }

  Future<void> initThemeMode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool? isDark = prefs.getBool(KConstants.themeModeKey);
    isDarkModeNotifier.value = isDark ?? false;
  }

  @override
  void dispose() {
    appStateNotifier?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If not initialized yet, use the simple notifiers to render a stable app while prefs load.
    if (!_initialized || appStateNotifier == null) {
      return MaterialApp(
        navigatorKey: navigatorKey,
        title: KConstants.appName,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: isDarkModeNotifier.value ? ThemeMode.dark : ThemeMode.light,
        locale: appLocale.value,
        routes: {
          '/petition': (ctx) {
            final args = ModalRoute.of(ctx)?.settings.arguments as String?;
            return PetitionDetailPage(id: args ?? '');
          },
          '/poll': (ctx) {
            final args = ModalRoute.of(ctx)?.settings.arguments as String?;
            return PollDetailPage(id: args ?? '');
          },
        },
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        debugShowCheckedModeBanner: false,
        home: const InitAppLayout(),
      );
    }

    return ValueListenableBuilder<AppState>(
      valueListenable: appStateNotifier!,
      builder: (context, state, child) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          title: KConstants.appName,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: state.isDark ? ThemeMode.dark : ThemeMode.light,
          locale: state.locale,
          routes: {
            '/petition': (ctx) {
              final args = ModalRoute.of(ctx)?.settings.arguments as String?;
              return PetitionDetailPage(id: args ?? '');
            },
            '/poll': (ctx) {
              final args = ModalRoute.of(ctx)?.settings.arguments as String?;
              return PollDetailPage(id: args ?? '');
            },
          },
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          debugShowCheckedModeBanner: false,
          home: const InitAppLayout(),
        );
      },
    );
  }
}
