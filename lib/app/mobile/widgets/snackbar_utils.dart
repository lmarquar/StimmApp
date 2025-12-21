import 'package:flutter/material.dart';
import 'package:stimmapp/core/theme/app_text_styles.dart';
import 'package:stimmapp/main.dart'; // to access navigatorKey

/// Show a floating success snackbar. [message] is optional.
void showSuccessSnackBar([String? message]) {
  final ctx = navigatorKey.currentContext;
  if (ctx == null) return;
  final messenger = ScaffoldMessenger.of(ctx);
  messenger.clearSnackBars();
  messenger.showSnackBar(
    SnackBar(
      backgroundColor: Theme.of(ctx).colorScheme.primary,
      behavior: SnackBarBehavior.floating,
      content: Text(message ?? '', style: AppTextStyles.m),
      showCloseIcon: true,
    ),
  );
}

/// Show a floating error snackbar. [message] is optional.
void showErrorSnackBar([String? message]) {
  final ctx = navigatorKey.currentContext;
  if (ctx == null) return;
  final messenger = ScaffoldMessenger.of(ctx);
  messenger.clearSnackBars();
  messenger.showSnackBar(
    SnackBar(
      backgroundColor: Theme.of(ctx).colorScheme.error,
      behavior: SnackBarBehavior.floating,
      content: Text(message ?? '', style: AppTextStyles.m),
      showCloseIcon: true,
    ),
  );
}
