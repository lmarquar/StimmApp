import 'package:flutter/material.dart';
import '../constants/app_dimensions.dart';
import '../constants/constants.dart';
import 'app_text_styles.dart';

class AppTheme {
  static final ThemeData light = ThemeData(
    useMaterial3: true,
    fontFamily: AppTextStyles.fontFamily,
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(AppDimensions.kBorderRadius10),
        ),
      ),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: KConstants.appColor,
      primary: KConstants.lightColor,
      brightness: Brightness.light,
    ),
  );

  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    fontFamily: AppTextStyles.fontFamily,
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(AppDimensions.kBorderRadius10),
        ),
      ),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: KConstants.appColor,
      primary: KConstants.appColor,
      brightness: Brightness.dark,
    ),
  );
}
