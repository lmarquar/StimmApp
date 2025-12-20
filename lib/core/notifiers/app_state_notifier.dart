import 'package:flutter/widgets.dart';
import 'package:stimmapp/core/notifiers/notifiers.dart';

class AppState {
  final bool isDark;
  final Locale? locale;
  const AppState(this.isDark, this.locale);
}

/// Notifier that combines isDarkModeNotifier and appLocale into a single ValueListenable.
class AppStateNotifier extends ValueNotifier<AppState> {
  AppStateNotifier(bool isDark, Locale? locale)
    : super(AppState(isDark, locale)) {
    _update = _updateImpl;
    isDarkModeNotifier.addListener(_update);
    appLocale.addListener(_update);
  }

  late final VoidCallback _update;

  void _updateImpl() {
    value = AppState(isDarkModeNotifier.value, appLocale.value);
  }

  @override
  void dispose() {
    isDarkModeNotifier.removeListener(_update);
    appLocale.removeListener(_update);
    super.dispose();
  }
}
