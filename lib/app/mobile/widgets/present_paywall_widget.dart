import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:stimmapp/core/data/models/user_profile.dart';
import 'package:stimmapp/core/data/repositories/user_repository.dart';
import 'package:stimmapp/app/mobile/widgets/snackbar_utils.dart';

/// NOTE: _performPurchase currently simulates a successful purchase.
/// Replace the body with your RevenueCat integration (purchases_flutter or revenuecat SDK)
/// and return true only when the purchase/subscription is confirmed.
Future<bool> _performPurchase() async {
  await Future.delayed(
    const Duration(seconds: 2),
  ); // simulate network / purchase flow
  log('Simulated purchase succeeded');
  return true;
}

Future<bool> presentPaywall(BuildContext context, UserProfile user) async {
  log('Presenting paywall for user ${user.uid}');
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (dialogCtx) {
      return AlertDialog(
        title: const Text('Pro Annual — €12 / year'),
        content: const Text(
          'Unlock Pro features for €12 per year. Subscribe to support the app and get full access.',
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
            child: const Text('Subscribe for €1 a month'),
          ),
        ],
      );
    },
  );

  log('Paywall dialog closed: $result');
  return result ?? false;
}

Future<void> presentPaywallIfNeeded(
  BuildContext context,
  UserProfile? user,
) async {
  if (user == null || (user.isPro ?? false)) return;
  await presentPaywall(context, user);
}
