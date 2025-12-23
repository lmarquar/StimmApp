import 'package:stimmapp/app/mobile/widgets/hero_widget.dart';
import 'package:stimmapp/app/mobile/widgets/snackbar_utils.dart';
import 'package:stimmapp/core/extensions/context_extensions.dart';
import 'package:stimmapp/core/theme/app_text_styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stimmapp/app/mobile/pages/others/change_password_page.dart';
import 'package:stimmapp/app/mobile/pages/others/update_username_page.dart';
import 'package:stimmapp/app/mobile/pages/others/user_history.dart';
import 'package:stimmapp/core/constants/app_dimensions.dart';
import 'package:stimmapp/core/services/auth_service.dart';
import 'package:stimmapp/core/services/profile_picture_service.dart';
import 'package:stimmapp/app/mobile/pages/main/profile/change_profile_picture_page.dart';
import '../../../../../../core/notifiers/notifiers.dart';
import '../../../../scaffolds/app_padding_scaffold.dart';
import '../../../../widgets/list_tile_widget.dart';
import '../../../../widgets/neon_padding_widget.dart';
import '../../../../widgets/unaffected_child_widget.dart';
import '../../../others/delete_account_page.dart';

class ProfileWidget extends StatelessWidget {
  const ProfileWidget({super.key});

  @override
  Widget build(BuildContext context) {
    void popUntilLast() {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }

    void logout() async {
      try {
        await authService.value.signOut();
        AppData.isAuthConnected.value = false;
        AppData.navBarCurrentIndexNotifier.value = 0;
        AppData.onboardingCurrentIndexNotifier.value = 0;
        popUntilLast();
      } on FirebaseAuthException catch (e) {
        showErrorSnackBar(e.message);
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
              HeroWidget(nextPage: const ChangeProfilePicturePage()),
              Text(
                authService.value.currentUser!.displayName ??
                    'no username found',
                style: AppTextStyles.l,
              ),
              Text(
                authService.value.currentUser!.email ??
                    'error retrieving email',
                style: AppTextStyles.m,
              ),
              const SizedBox(height: AppDimensions.kPadding5),
            ],
          ),
        ),
        const SizedBox(height: 20.0),
        // avatar display: use service notifier (updates after upload)
        ValueListenableBuilder<String?>(
          valueListenable: ProfilePictureService.instance.profileUrlNotifier,
          builder: (context, profileUrl, child) {
            return ListTileWidget(
              title: Text(context.l10n.settings, style: AppTextStyles.xlBold),
            );
          },
        ),

        // Update username
        UnaffectedChildWidget(
          child: Material(
            type: MaterialType.transparency,
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
        ),

        //Change password
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

        ListTileWidget(
          title: Text(context.l10n.other, style: AppTextStyles.xlBold),
        ),

        UnaffectedChildWidget(
          child: ListTile(
            trailing: const Icon(
              Icons.arrow_forward_ios_outlined,
              color: Colors.white38,
            ),
            title: Text(context.l10n.activityHistory),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const UserHistoryPage();
                  },
                ),
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
                          popUntilLast();
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

  void showSnackBarFailure() {}
}
