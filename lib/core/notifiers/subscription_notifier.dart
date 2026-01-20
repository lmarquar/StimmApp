import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:stimmapp/core/services/purchases_service.dart';

class SubscriptionNotifier extends ChangeNotifier {
  late StreamSubscription<EntitlementTier> _subscription;
  EntitlementTier _status = EntitlementTier.free;

  EntitlementTier get status => _status;

  bool get isPro => _status == EntitlementTier.pro;
  bool get isBasic => _status == EntitlementTier.basic;
  bool get isFree => _status == EntitlementTier.free;

  /// Helper to determine if ads should be shown (e.g., only for free users).
  bool get shouldShowAds => isFree;

  SubscriptionNotifier() {
    _init();
  }

  void _init() {
    // Initialize with current status from service immediately
    _status = PurchasesService.instance.currentStatus;

    // Listen for future updates
    _subscription = PurchasesService.instance.entitlementStream.listen((
      newStatus,
    ) {
      if (_status != newStatus) {
        _status = newStatus;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
