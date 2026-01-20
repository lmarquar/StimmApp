import 'dart:async';
import 'dart:developer';

import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

/*// on startup:
await PurchasesService.instance.init(apiKey: 'your_public_sdk_key');

// listen globally (e.g. in a provider or bloc):
PurchasesService.instance.entitlementStream.listen((status) {
  // update UI / state based on status
});

// show paywall:
await PurchasesService.instance.presentPaywall();

// check current entitlement synchronously:
final status = PurchasesService.instance.currentStatus;
*/

/// Simple enum for your app logic.
enum EntitlementStatus { none, active, expired, unknown }

enum EntitlementTier { free, basic, pro }

class PurchasesService {
  PurchasesService._internal();
  static final PurchasesService _instance = PurchasesService._internal();
  static PurchasesService get instance => _instance;

  /// Stream with the current entitlement status for the main entitlement.
  final _entitlementController = StreamController<EntitlementTier>.broadcast();

  Stream<EntitlementTier> get entitlementStream =>
      _entitlementController.stream;

  /// Last known status (cached in memory).
  EntitlementTier _currentStatus = EntitlementTier.free;
  EntitlementTier get currentStatus => _currentStatus;

  /// The entitlement identifiers you configured in RevenueCat.
  static const String _proEntitlementId = 'premium';
  static const String _basicEntitlementId = 'basic';

  /// Call this early in app startup.
  Future<void> init({required String apiKey, String? appUserId}) async {
    try {
      await Purchases.configure(
        PurchasesConfiguration(apiKey)..appUserID = appUserId,
      );

      // Listen to any customer info changes (restores, purchases, etc.).
      Purchases.addCustomerInfoUpdateListener(_onCustomerInfoUpdated);

      // Fetch initial state.
      final info = await Purchases.getCustomerInfo();
      _onCustomerInfoUpdated(info);
    } catch (e, st) {
      log('PurchasesService.init error: $e\n$st');
    }
  }

  void _onCustomerInfoUpdated(CustomerInfo info) {
    try {
      EntitlementTier tier = EntitlementTier.free;

      // Check for Pro first (highest tier)
      if (info.entitlements.all[_proEntitlementId]?.isActive == true) {
        tier = EntitlementTier.pro;
      } else if (info.entitlements.all[_basicEntitlementId]?.isActive == true) {
        tier = EntitlementTier.basic;
      }

      if (_currentStatus != tier) {
        _currentStatus = tier;
        _entitlementController.add(tier);
        log('Entitlement updated: $tier');
      }
    } catch (e, st) {
      log('PurchasesService._onCustomerInfoUpdated error: $e\n$st');
    }
  }

  /// Restore purchases (required for iOS).
  Future<void> restorePurchases() async {
    try {
      final info = await Purchases.restorePurchases();
      _onCustomerInfoUpdated(info);
    } catch (e, st) {
      log('restorePurchases error: $e\n$st');
    }
  }

  /// Hosted paywall – returns true on success.
  Future<bool> presentPaywall() async {
    try {
      final result = await RevenueCatUI.presentPaywall();
      log('presentPaywall result: $result');
      return true;
    } catch (e, st) {
      log('presentPaywall error: $e\n$st');
      return false;
    }
  }

  /// Specific hosted paywall if needed – returns true on success.
  Future<bool> presentPaywallIfNeeded(String paywallId) async {
    try {
      final result = await RevenueCatUI.presentPaywallIfNeeded(paywallId);
      log('presentPaywallIfNeeded($paywallId) result: $result');
      return true;
    } catch (e, st) {
      log('presentPaywallIfNeeded error: $e\n$st');
      return false;
    }
  }

  /// Convenience: refresh customer info and entitlement.
  Future<void> refreshCustomerInfo() async {
    try {
      final info = await Purchases.getCustomerInfo();
      _onCustomerInfoUpdated(info);
    } catch (e, st) {
      log('refreshCustomerInfo error: $e\n$st');
    }
  }

  /// Log out current user and clear state.
  Future<void> logOut() async {
    try {
      await Purchases.logOut();
      _currentStatus = EntitlementTier.free;
      _entitlementController.add(_currentStatus);
    } catch (e, st) {
      log('PurchasesService.logOut error: $e\n$st');
    }
  }

  /// Dispose when app shuts down (usually not necessary on mobile).
  Future<void> dispose() async {
    await _entitlementController.close();
  }
}
