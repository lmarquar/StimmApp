import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stimmapp/app/mobile/layout/init_app_layout.dart';
import 'package:stimmapp/app/mobile/pages/main/home/petition_detail_page.dart';
import 'package:stimmapp/app/mobile/pages/main/home/poll_detail_page.dart';
import 'package:stimmapp/core/constants/constants.dart';
import 'package:stimmapp/core/notifiers/notifiers.dart';
import 'package:stimmapp/core/firebase/firebase_options.dart';
import 'package:stimmapp/core/errors/error_log_tool.dart';
import 'package:stimmapp/core/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:stimmapp/core/di/service_locator.dart';

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
  @override
  void initState() {
    super.initState();
    initThemeMode();
  }

  Future<void> initThemeMode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool? isDark = prefs.getBool(KConstants.themeModeKey);
    isDarkModeNotifier.value = isDark ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDarkMode, child) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          title: KConstants.appName,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
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
          home: const InitAppLayout(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
