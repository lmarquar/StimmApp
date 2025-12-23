
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:stimmapp/l10n/app_localizations.dart';

Widget createTestWidget(Widget child) {
  return MaterialApp(
    locale: const Locale('en', ''),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [
      Locale('en', ''),
    ],
    home: child,
  );
}
