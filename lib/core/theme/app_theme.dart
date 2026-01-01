import 'package:flutter/material.dart';
import '../constants/app_dimensions.dart';
import '../constants/internal_constants.dart';
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
      seedColor: IConst.appColor,
      primary: IConst.lightColor,
      secondary: Colors.red,
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
      seedColor: IConst.appColor,
      primary: IConst.appColor,
      brightness: Brightness.dark,
    ),
  );
}
