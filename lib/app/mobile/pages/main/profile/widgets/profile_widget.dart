import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stimmapp/app/mobile/pages/main/profile/profile_settings/change_password_page.dart';
import 'package:stimmapp/app/mobile/pages/main/profile/profile_settings/change_profile_picture_page.dart';
import 'package:stimmapp/app/mobile/pages/main/profile/profile_settings/update_living_address_page.dart';
import 'package:stimmapp/app/mobile/pages/main/profile/profile_settings/update_username_page.dart';
import 'package:stimmapp/app/mobile/pages/main/profile/user_history.dart';
import 'package:stimmapp/app/mobile/widgets/hero_widget.dart';
import 'package:stimmapp/app/mobile/widgets/snackbar_utils.dart';
import 'package:stimmapp/core/data/models/user_profile.dart';
import 'package:stimmapp/core/data/repositories/user_repository.dart';
import 'package:stimmapp/core/data/services/auth_service.dart';
import 'package:stimmapp/core/extensions/context_extensions.dart';
import 'package:stimmapp/core/services/purchases_service.dart';
import 'package:stimmapp/core/theme/app_text_styles.dart';

import '../../../../../../core/notifiers/notifiers.dart';
import '../../../../scaffolds/app_padding_scaffold.dart';
import '../../../../widgets/neon_padding_widget.dart';
import '../../../../widgets/pointing_list_tile.dart';
import '../../admin/admin_dashboard_page.dart';
import '../../profile/form_export_page.dart';
import '../delete_account_page.dart';

class ProfileWidget extends StatelessWidget {
  const ProfileWidget({super.key});

  @override
  Widget build(BuildContext context) {
    void popUntilLast() {
      if (context.mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }

    void logout() async {
      try {
        // Pop the dialog first if it's showing
        popUntilLast();
        await authService.signOut();
        AppData.isAuthConnected.value = false;
        AppData.navBarCurrentIndexNotifier.value = 0;
        AppData.onboardingCurrentIndexNotifier.value = 0;
      } on AuthException catch (e) {
        if (context.mounted) {
          showErrorSnackBar(e.message);
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: AppPaddingScaffold(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10.0),
          StreamBuilder<UserProfile?>(
            stream: UserRepository.create().watchById(
              authService.currentUser!.uid,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Text('${context.l10n.error}${snapshot.error}');
              }
              if (!snapshot.hasData || snapshot.data == null) {
                return Text(context.l10n.userNotFound);
              }

              final userProfile = snapshot.data!;
              final dateFormat = DateFormat('yyyy-MM-dd');

              return Column(
                children: [
                  NeonPaddingWidget(
                    isCentered: true,
                    child: Column(
                      children: [
                        HeroWidget(nextPage: const ChangeProfilePicturePage()),
                        const SizedBox(height: 10),
                        _buildDetailTile(
                          context,
                          context.l10n.surname,
                          userProfile.surname,
                        ),
                        _buildDetailTile(
                          context,
                          context.l10n.givenName,
                          userProfile.givenName,
                        ),
                        _buildDetailTile(
                          context,
                          context.l10n.dateOfBirth,
                          userProfile.dateOfBirth != null
                              ? dateFormat.format(userProfile.dateOfBirth!)
                              : null,
                        ),
                        _buildDetailTile(
                          context,
                          context.l10n.placeOfBirth,
                          userProfile.placeOfBirth,
                        ),
                        _buildDetailTile(
                          context,
                          context.l10n.nationality,
                          userProfile.nationality,
                        ),
                        _buildDetailTile(
                          context,
                          context.l10n.idNumber,
                          userProfile.idNumber,
                        ),
                        _buildDetailTile(
                          context,
                          context.l10n.expiryDate,
                          userProfile.expiryDate != null
                              ? dateFormat.format(userProfile.expiryDate!)
                              : null,
                        ),
                        _buildDetailTile(
                          context,
                          context.l10n.height,
                          userProfile.height,
                        ),
                        _buildDetailTile(
                          context,
                          context.l10n.address,
                          userProfile.address,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UpdateLivingAddressPage(),
                              ),
                            );
                          },
                        ),
                        _buildDetailTile(
                          context,
                          context.l10n.state,
                          userProfile.state,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UpdateLivingAddressPage(),
                              ),
                            );
                          },
                        ),
                        _buildDetailTile(
                          context,
                          context.l10n.email,
                          userProfile.email,
                        ),
                        _buildDetailTile(
                          context,
                          context.l10n.nickname,
                          userProfile.displayName,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UpdateUsernamePage(),
                              ),
                            );
                          },
                        ),

                        _buildDetailTile(
                          context,
                          context.l10n.isProMember,
                          userProfile.isPro == true
                              ? context.l10n.yes
                              : context.l10n.no,
                          onTap: () {
                            PurchasesService.instance.presentPaywall();
                          },
                        ),
                        if (userProfile.isAdmin) ...[
                          const SizedBox(height: 20.0),
                          PointingListTile(
                            leading: const Icon(
                              Icons.admin_panel_settings,
                              color: Colors.amber,
                            ),
                            title: Text(context.l10n.adminInterface),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const AdminDashboardPage(),
                                ),
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20.0),
          // avatar display: use service notifier (updates after upload)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                // Update username
                PointingListTile(
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
                // Finished forms export
                PointingListTile(
                  title: Text(context.l10n.finishedForms),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FormExportPage(),
                      ),
                    );
                  },
                ),

                //Change password
                PointingListTile(
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

                // Logout
                PointingListTile(
                  title: Text(context.l10n.logout, style: AppTextStyles.red),
                  trailing: const SizedBox.shrink(),
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
                //   PointingListTile(
                //     title: Text(context.l10n.membershipStatus),
                //     onTap: () async {
                //       Navigator.push(
                //         context,
                //         MaterialPageRoute(
                //           builder: (context) {
                //             return const MembershipStatusPage();
                //           },
                //         ),
                //       );
                //     },
                //   ),

                // Delete my account
                PointingListTile(
                  title: Text(
                    context.l10n.deleteMyAccount,
                    style: AppTextStyles.red,
                  ),
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
              ],
            ),
          ),
          const SizedBox(height: 20.0),
        ],
      ),
    );
  }

  void showSnackBarFailure() {}

  Widget _buildDetailTile(
    BuildContext context,
    String label,
    String? value, {
    VoidCallback? onTap,
  }) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return ListTile(
      title: Text(label, style: AppTextStyles.descriptionText),
      subtitle: Text(value, style: AppTextStyles.mBold),
      dense: true,
      onTap: onTap,
      trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
    );
  }
}
