import 'dart:async';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stimmapp/app/mobile/layout/init_app_layout.dart';
import 'package:stimmapp/app/mobile/pages/main/home/petitions/petition_detail_page.dart';
import 'package:stimmapp/app/mobile/pages/main/home/polls/poll_detail_page.dart';
import 'package:stimmapp/core/constants/internal_constants.dart';
import 'package:stimmapp/core/data/services/auth_service.dart';
import 'package:stimmapp/core/data/services/profile_picture_service.dart';
import 'package:stimmapp/core/data/repositories/petition_repository.dart';
import 'package:stimmapp/core/data/repositories/poll_repository.dart';
import 'package:stimmapp/core/notifiers/app_state_notifier.dart';
import 'package:stimmapp/core/notifiers/notifiers.dart';
import 'package:stimmapp/core/data/firebase/firebase_options.dart';
import 'package:stimmapp/core/errors/error_log_tool.dart';
import 'package:stimmapp/core/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:stimmapp/core/data/di/service_locator.dart';
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
    name: IConst.appName,
    options: DefaultFirebaseOptions.currentPlatform,
  );
  locator.init();
  initializeAuthService();
  // Note: Only enable this for test builds
  if (!kIsWeb) {
    await authService.value.setSettings(
      appVerificationDisabledForTesting: true,
    );
  }

  // Initialize service locator (Firestore, repositories, etc.)

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
  StreamSubscription<User?>? _authSub;

  @override
  void initState() {
    super.initState();
    _initAsync();
  }

  Future<void> _initAsync() async {
    // load persisted theme first
    await initThemeMode();
    // load persisted locale (if any) before creating composite notifier
    await initLocale();

    // Close expired petitions on startup
    await PetitionRepository.create().closeExpiredPetitions();
    await PollRepository.create().closeExpiredPolls();

    // only create the composite notifier after persisted state is loaded to avoid immediate circular updates
    appStateNotifier = AppStateNotifier(
      isDarkModeNotifier.value,
      appLocale.value,
    );

    // Persist runtime locale changes immediately so selection becomes global/persistent.
    appLocale.addListener(_onLocaleChanged);

    // Load profile URL when user signs in and clear on sign-out
    _authSub = authService.value.authStateChanges.listen((user) {
      if (user != null) {
        ProfilePictureService.instance.loadProfileUrl(user.uid);
      } else {
        ProfilePictureService.instance.profileUrlNotifier.value = null;
      }
    });

    setState(() {
      _initialized = true;
    });
  }

  void _onLocaleChanged() async {
    final Locale? loc = appLocale.value;
    final prefs = await SharedPreferences.getInstance();
    final String toSave = (loc == null)
        ? ''
        : (loc.countryCode == null || loc.countryCode!.isEmpty)
        ? loc.languageCode
        : '${loc.languageCode}_${loc.countryCode}';
    await prefs.setString(IConst.localeKey, toSave);
    debugPrint('[main] persisted locale: $toSave');
  }

  Future<void> initThemeMode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool? isDark = prefs.getBool(IConst.themeModeKey);
    isDarkModeNotifier.value = isDark ?? false;
  }

  Future<void> initLocale() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? localeStr = prefs.getString(IConst.localeKey);
    if (localeStr != null && localeStr.isNotEmpty) {
      appLocale.value = _localeFromString(localeStr);
    }
  }

  Locale? _localeFromString(String s) {
    // "en" or "en_US"
    if (s.isEmpty) return null;
    final parts = s.split('_');
    if (parts.length == 1) return Locale(parts[0]);
    return Locale(parts[0], parts[1]);
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _authSub = null;
    appLocale.removeListener(_onLocaleChanged);
    appStateNotifier?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If not initialized yet, use the simple notifiers to render a stable app while prefs load.
    if (!_initialized || appStateNotifier == null) {
      return MaterialApp(
        navigatorKey: navigatorKey,
        title: IConst.appName,
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
          title: IConst.appName,
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
