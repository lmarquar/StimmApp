import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:stimmapp/app/mobile/scaffolds/app_bottom_bar_buttons.dart';
import 'package:stimmapp/app/mobile/widgets/button_widget.dart';
import 'package:stimmapp/app/mobile/widgets/snackbar_utils.dart';
import 'package:stimmapp/core/data/models/user_profile.dart';
import 'package:stimmapp/core/data/repositories/user_repository.dart';
import 'package:stimmapp/core/data/services/auth_service.dart';
import 'package:stimmapp/core/extensions/context_extensions.dart';
import 'package:stimmapp/core/theme/app_text_styles.dart';
import 'package:stimmapp/app/mobile/widgets/present_paywall_widget.dart';

class MembershipStatusPage extends StatelessWidget {
  const MembershipStatusPage({super.key});

  static final List<Map<String, Object>> _proBenefits = [
    {'icon': Icons.image, 'text': 'Custom petition and poll pictures'},
    {'icon': Icons.block, 'text': 'No advertisements'},
    {'icon': Icons.star, 'text': 'Priority support'},
    {'icon': Icons.more_horiz, 'text': 'More benefits to be added later'},
  ];

  @override
  Widget build(BuildContext context) {
    final uid = authService.currentUser?.uid;

    if (uid == null) {
      return Scaffold(
        appBar: AppBar(title: Text(context.l10n.membershipStatus)),
        body: const Center(child: Text('Not authenticated')),
      );
    }

    return StreamBuilder<UserProfile?>(
      stream: UserRepository.create().watchById(uid),
      builder: (context, snapshot) {
        final user = snapshot.data;
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final isPro = user?.isPro ?? false;

        return AppBottomBarButtons(
          appBar: AppBar(title: Text(context.l10n.membershipStatus)),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isPro ? Icons.verified : Icons.person_outline,
                    size: 100,
                    color: isPro
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    isPro ? 'Pro Member' : 'Free Member',
                    style: AppTextStyles.xxlBold,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isPro
                        ? 'You subscribed to following benefits'
                        : 'Go pro to access these benefits',
                    style: AppTextStyles.xlBold,
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(_proBenefits.length, (i) {
                      final item = _proBenefits[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Icon(
                              item['icon'] as IconData,
                              size: 20,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item['text'] as String,
                                style: AppTextStyles.m,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  if (isLoading) ...[
                    const SizedBox(height: 40),
                    const CircularProgressIndicator(),
                  ],
                ],
              ),
            ),
          ),
          buttons: [
            if (!isPro && user != null)
              ButtonWidget(
                label: 'Sign up for Pro',
                isFilled: true,
                callback: isLoading
                    ? () {}
                    : () async {
                        // present the paywall and handle purchase + upgrade inside widget
                        await presentPaywall(context, user);
                      },
              )
            else
              ButtonWidget(
                label: 'Cancel subscription',
                isFilled: false,
                callback: isLoading
                    ? () {}
                    : () async {
                        // present the paywall and handle purchase + upgrade inside widget
                        await cancelProMembership(context, user);
                      },
              ),
          ],
        );
      },
    );
  }

  Future<void> cancelProMembership(
    BuildContext context,
    UserProfile? user,
  ) async {
    if (user == null) {
      showErrorSnackBar('User not available');
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Text('Cancel Pro Subscription'),
          content: const Text(
            'Are you sure you want to cancel your Pro subscription? You will lose Pro features.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(false),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogCtx).pop(true),
              child: const Text('Yes, cancel'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      // Update user to revoke pro status locally
      await UserRepository.create().upsert(
        user.copyWith(isPro: false, wentProAt: null),
      );
      if (context.mounted) showSuccessSnackBar('Pro subscription cancelled');
      log('User cancelled Pro: ${user.uid}');
      // TODO: also revoke subscription via RevenueCat / App Store / Play Store if needed
    } catch (e) {
      log('Error cancelling Pro membership: $e');
      if (context.mounted) showErrorSnackBar(e.toString());
    }
  }
}
