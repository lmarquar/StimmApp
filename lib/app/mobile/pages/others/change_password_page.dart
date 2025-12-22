import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stimmapp/app/mobile/scaffolds/app_bottom_bar_buttons.dart';
import 'package:stimmapp/app/mobile/widgets/button_widget.dart';
import 'package:stimmapp/app/mobile/widgets/snackbar_utils.dart';
import 'package:stimmapp/core/extensions/context_extensions.dart';
import 'package:stimmapp/core/firebase/auth_service.dart';
import 'package:stimmapp/core/theme/app_text_styles.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  TextEditingController controllerCurrentPassword = TextEditingController();
  TextEditingController controllerNewPassword = TextEditingController();
  final formKey = GlobalKey<FormState>();
  String errorMessage = '';

  @override
  void dispose() {
    controllerCurrentPassword.dispose();
    controllerNewPassword.dispose();
    super.dispose();
  }

  void updatePassword() async {
    // Capture localized messages before the async gap
    final successMessage = context.l10n.passwordChangedSuccessfully;
    final failureMessage = context.l10n.passwordChangeFailed;

    try {
      await authService.value.resetPasswordfromCurrentPassword(
        currentPassword: controllerCurrentPassword.text,
        newPassword: controllerNewPassword.text,
        email: AuthService().currentUser!.email!,
      );
      if (!mounted) return;
      showSuccessSnackBar(successMessage);
    } catch (e) {
      if (!mounted) return;
      if (e is FirebaseException) {
        showErrorSnackBar(e.message ?? 'Unknown error');
        return;
      }
      showErrorSnackBar(failureMessage + e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomBarButtons(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 60.0),
                Text(context.l10n.changePassword, style: AppTextStyles.xxlBold),
                const SizedBox(height: 20.0),
                const Text('🔐', style: AppTextStyles.icons),
                const SizedBox(height: 50),
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        obscureText: true,
                        controller: controllerCurrentPassword,
                        decoration: InputDecoration(
                          labelText: context.l10n.currentPassword,
                        ),
                        validator: (String? value) {
                          if (value == null) {
                            return context.l10n.enterSomething;
                          }
                          if (value.trim().isEmpty) {
                            return context.l10n.enterSomething;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        obscureText: true,
                        controller: controllerNewPassword,
                        decoration: InputDecoration(
                          labelText: context.l10n.newPassword,
                        ),
                        validator: (String? value) {
                          if (value == null) {
                            return context.l10n.enterSomething;
                          }
                          if (value.trim().isEmpty) {
                            return context.l10n.enterSomething;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      Text(
                        errorMessage,
                        style: AppTextStyles.m.copyWith(
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      buttons: [
        ButtonWidget(
          isFilled: true,
          label: context.l10n.changePassword,
          callback: () async {
            if (formKey.currentState!.validate()) {
              updatePassword();
            }
          },
        ),
      ],
    );
  }
}
