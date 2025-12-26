import 'package:flutter/material.dart';
import 'package:stimmapp/app/mobile/pages/main/profile/change_password_page.dart';
import 'package:stimmapp/app/mobile/pages/main/profile/delete_account_page.dart';
import 'package:stimmapp/app/mobile/pages/main/profile/update_username_page.dart';
import 'package:stimmapp/core/constants/app_dimensions.dart';
import 'package:stimmapp/core/data/services/auth_service.dart';
import 'package:stimmapp/core/extensions/context_extensions.dart';
import 'package:stimmapp/core/theme/app_text_styles.dart';

import '../../../../core/notifiers/notifiers.dart';
import '../scaffolds/app_padding_scaffold.dart';
import 'list_tile_widget.dart';
import 'neon_padding_widget.dart';
import 'unaffected_child_widget.dart';

class ProfileWidget extends StatelessWidget {
  const ProfileWidget({super.key});

  @override
  Widget build(BuildContext context) {
    void popPage() {
      Navigator.pop(context);
    }

    void logout() async {
      try {
        AppData.isAuthConnected.value = false;
        AppData.navBarCurrentIndexNotifier.value = 0;
        AppData.onboardingCurrentIndexNotifier.value = 0;
        popPage();
      } on AuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unexpected error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    return AppPaddingScaffold(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10.0),
        NeonPaddingWidget(
          isCentered: true,
          child: Column(
            children: [
              const Text('😊', style: AppTextStyles.icons),
              Text(context.l10n.flutterPro, style: AppTextStyles.l),
              Text(
                context.l10n.flutterProEmail,
                style: AppTextStyles.m.copyWith(color: Colors.white54),
              ),
              const SizedBox(height: AppDimensions.kPadding5),
            ],
          ),
        ),
        const SizedBox(height: 20.0),
        ListTileWidget(
          title: Text(context.l10n.settings, style: AppTextStyles.xlBold),
        ),

        // Update username
        UnaffectedChildWidget(
          child: ListTile(
            trailing: const Icon(
              Icons.arrow_forward_ios_outlined,
              color: Colors.white38,
            ),
            title: Text(context.l10n.updateUsername),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return UpdateUsernamePage();
                  },
                ),
              );
            },
          ),
        ),

        // Change password
        UnaffectedChildWidget(
          child: ListTile(
            trailing: const Icon(
              Icons.arrow_forward_ios_outlined,
              color: Colors.white38,
            ),
            title: Text(context.l10n.changePassword),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return ChangePasswordPage();
                  },
                ),
              );
            },
          ),
        ),

        // Delete my account
        UnaffectedChildWidget(
          child: ListTile(
            trailing: const Icon(
              Icons.arrow_forward_ios_outlined,
              color: Colors.white38,
            ),
            title: Text(context.l10n.deleteMyAccount),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const DeleteAccountPage();
                  },
                ),
              );
            },
          ),
        ),

        // About this app
        UnaffectedChildWidget(
          child: ListTile(
            title: Text(context.l10n.aboutThisApp),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text(context.l10n.flutterPro),
                    content: Text(
                      context.l10n.aboutThisApp,
                      style: AppTextStyles.m,
                    ),
                    actions: [
                      FilledButton(
                        onPressed: () async {
                          popPage();
                          showLicensePage(context: context);
                        },
                        child: Text(context.l10n.viewLicenses),
                      ),
                      TextButton(
                        onPressed: () {
                          popPage();
                        },
                        child: Text(context.l10n.close),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),

        // Logout
        UnaffectedChildWidget(
          child: ListTile(
            title: Text(context.l10n.logout, style: AppTextStyles.red),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text(context.l10n.logout),
                    content: Text(
                      context.l10n.areYouSureYouWantToLogout,
                      style: AppTextStyles.m,
                    ),
                    actions: [
                      FilledButton(
                        onPressed: () async {
                          logout();
                        },
                        child: Text(context.l10n.logout),
                      ),
                      TextButton(
                        onPressed: () {
                          popPage();
                        },
                        child: Text(context.l10n.cancel),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 20.0),
      ],
    );
  }
}
