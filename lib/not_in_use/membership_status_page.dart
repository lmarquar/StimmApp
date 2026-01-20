import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stimmapp/app/mobile/scaffolds/app_bottom_bar_buttons.dart';
import 'package:stimmapp/app/mobile/widgets/button_widget.dart';
import 'package:stimmapp/app/mobile/widgets/snackbar_utils.dart';
import 'package:stimmapp/core/data/models/user_profile.dart';
import 'package:stimmapp/core/data/repositories/user_repository.dart';
import 'package:stimmapp/core/data/services/auth_service.dart';
import 'package:stimmapp/core/extensions/context_extensions.dart';
import 'package:stimmapp/core/theme/app_text_styles.dart';
import 'package:stimmapp/not_in_use/present_paywall_widget.dart';

// TODO Membership status page needs revenue cat setup needs playstore setup
class MembershipStatusPage extends StatefulWidget {
  const MembershipStatusPage({super.key});

  static List<Map<String, Object>> _proBenefits(BuildContext context) => [
    {'icon': Icons.image, 'text': context.l10n.customPetitionAndPollPictures},
    {'icon': Icons.block, 'text': context.l10n.noAdvertisements},
    {'icon': Icons.star, 'text': context.l10n.prioritySupport},
    {'icon': Icons.more_horiz, 'text': context.l10n.moreBenefitsToBeAddedLater},
  ];

  @override
  State<MembershipStatusPage> createState() => _MembershipStatusPageState();
}

class _MembershipStatusPageState extends State<MembershipStatusPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final uid = authService.currentUser?.uid;

    if (uid == null) {
      return Scaffold(
        appBar: AppBar(title: Text(context.l10n.membershipStatus)),
        body: Center(child: Text(context.l10n.notAuthenticated)),
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
                    isPro ? context.l10n.proMember : context.l10n.freeMember,
                    style: AppTextStyles.xxlBold,
                    textAlign: TextAlign.center,
                  ),
                  if (isPro && user?.subscriptionEndsAt != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.validUntil(
                        _formatDate(user!.subscriptionEndsAt!),
                      ),
                      style: AppTextStyles.m.copyWith(color: Colors.grey),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    isPro
                        ? context.l10n.youSubscribedToFollowingBenefits
                        : context.l10n.goProToAccessTheseBenefits,
                    style: AppTextStyles.xlBold,
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(
                      MembershipStatusPage._proBenefits(context).length,
                      (i) {
                        final item = MembershipStatusPage._proBenefits(
                          context,
                        )[i];
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
                      },
                    ),
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
            if (kIsWeb)
              ButtonWidget(
                isFilled: false,
                label: context.l10n.notAvailableOnWebApp,
                callback: () {},
              )
            else if (!isPro && user != null)
              ButtonWidget(
                label: context.l10n.signUpForPro,
                isFilled: true,
                callback: isLoading
                    ? () {}
                    : () async {
                        if (!context.mounted) return;
                        final ok = await presentPaywallWidget(context, user);
                        if (!ok && context.mounted) {
                          showErrorSnackBar(context.l10n.couldNotOpenPaywall);
                        }
                      },
              )
            else if (isPro && (user?.subscribedToPro ?? false))
              ButtonWidget(
                label: context.l10n.resubscribe,
                isFilled: true,
                callback: isLoading
                    ? () {}
                    : () async {
                        if (!context.mounted) return;
                        // flip cancellation flag and open paywall
                        try {
                          await UserRepository.create().upsert(
                            user!.copyWith(subscribedToPro: false),
                          );
                          if (!context.mounted) return;
                          final ok = await presentPaywallWidget(context, user);
                          if (!ok && context.mounted) {
                            showErrorSnackBar(context.l10n.couldNotOpenPaywall);
                          }
                        } catch (e) {
                          if (context.mounted) showErrorSnackBar(e.toString());
                        }
                      },
              )
            else
              ButtonWidget(
                label: context.l10n.cancelSubscription,
                isFilled: false,
                callback: isLoading
                    ? () {}
                    : () async {
                        await cancelProMembership(context, user);
                      },
              ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }

  Future<void> cancelProMembership(
    BuildContext context,
    UserProfile? user,
  ) async {
    if (user == null) {
      showErrorSnackBar(context.l10n.userNotAvailable);
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) {
        return AlertDialog(
          title: Text(context.l10n.cancelProSubscription),
          content: Text(
            context.l10n.areYouSureYouWantToCancelYourProSubscription,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(false),
              child: Text(context.l10n.no),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogCtx).pop(true),
              child: Text(context.l10n.yesCancel),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      // Mark subscription as cancelled but keep access until subscriptionEndsAt
      await UserRepository.create().upsert(
        user.copyWith(subscribedToPro: true),
      );
      if (context.mounted) {
        showSuccessSnackBar(
          context.l10n.subscriptionCancelledAccessWillRemainUntilExpiry,
        );
      }
      log('User requested cancel Pro: ${user.uid}');
      // Optionally call your server to revoke grants or open store subscription management
    } catch (e) {
      log('Error cancelling Pro membership: $e');
      if (context.mounted) showErrorSnackBar(e.toString());
    }
  }
}
