import 'package:flutter/widgets.dart';
import 'package:stimmapp/l10n/app_localizations.dart';

extension BuildContextExtensions on BuildContext {
  /// A convenient getter for AppLocalizations.
  ///
  /// Instead of `AppLocalizations.of(context)!`, you can now use `context.l10n`.
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
