import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:stimmapp/core/data/models/user_profile.dart';
import 'package:stimmapp/core/data/repositories/user_repository.dart';
import 'package:stimmapp/app/mobile/widgets/snackbar_utils.dart';

/// Perform a RevenueCat purchase. Returns true on success.
Future<bool> _performPurchase() async {
  try {
    final offerings = await Purchases.getOfferings();
    final offering = offerings.current;
    if (offering == null || offering.availablePackages.isEmpty) {
      log('No offering or packages available');
      return false;
    }

    // Choose a package. Adjust selection logic as needed (by identifier/period).
    final package = offering.availablePackages.first;

    // Use the new Purchase API (PurchaseParams) — use named constructor.
    try {
      final purchaseParams = PurchaseParams.package(package);
      PurchaseResult result = await Purchases.purchase(purchaseParams);
      if (result
              .customerInfo
              .entitlements
              .all["my_entitlement_identifier"]
              ?.isActive ??
          false) {
        // Unlock that great "pro" content
      }
    } on PlatformException catch (e) {
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        showErrorSnackBar(e.toString());
      }
    }

    // If no exception was thrown, consider the purchase flow successful.
    return true;
  } on PlatformException catch (e) {
    // RevenueCat/platform error
    log('RevenueCat purchase error: $e');
    return false;
  } catch (e, st) {
    log('Unknown purchase error: $e\n$st');
    return false;
  }
}

Future<bool> presentPaywallWidget(
  BuildContext context,
  UserProfile user,
) async {
  log('Presenting paywall for user ${user.uid}');
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (dialogCtx) {
      return AlertDialog(
        title: const Text('Pro Month — €1 / month'),
        content: const Text(
          'Unlock Pro features for 1 per month. Subscribe to support the app and get full access.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(
                dialogCtx,
              ).pop(false); // close dialog, handle purchase after
              final purchased = await _performPurchase();
              if (!purchased) {
                if (context.mounted) showErrorSnackBar('Purchase failed');
                log('Purchase failed or cancelled');
                return;
              }

              try {
                await UserRepository.create().upsert(
                  user.copyWith(isPro: true, wentProAt: DateTime.now()),
                );
                if (context.mounted) showSuccessSnackBar('Welcome to Pro!');
                log('User upgraded to Pro: ${user.uid}');
              } catch (e) {
                log('Error upgrading user to Pro: $e');
                if (context.mounted) showErrorSnackBar(e.toString());
              }
            },
            child: const Text('confirm'),
          ),
        ],
      );
    },
  );

  log('Paywall dialog closed: $result');
  return result ?? false;
}

Future<void> presentPaywallWidgetIfNeeded(
  BuildContext context,
  UserProfile? user,
) async {
  if (user == null || (user.isPro ?? false)) return;
  await presentPaywallWidget(context, user);
}
