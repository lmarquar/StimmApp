import 'dart:async';
import 'dart:developer';

import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

/// Presents the RevenueCat hosted paywall. Returns true on success.
Future<bool> presentPaywall() async {
  try {
    final paywallResult = await RevenueCatUI.presentPaywall();
    log('presentPaywall result: $paywallResult');
    return true;
  } catch (e, st) {
    log('presentPaywall error: $e\n$st');
    return false;
  }
}

/// Presents a specific hosted paywall (if-needed API). Returns true on success.
Future<bool> presentPaywallIfNeeded(String paywallId) async {
  try {
    final paywallResult = await RevenueCatUI.presentPaywallIfNeeded(paywallId);
    log('presentPaywallIfNeeded($paywallId) result: $paywallResult');
    return true;
  } catch (e, st) {
    log('presentPaywallIfNeeded error: $e\n$st');
    return false;
  }
}
