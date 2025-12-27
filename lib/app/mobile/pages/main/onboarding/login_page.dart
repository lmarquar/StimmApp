import 'package:flutter/material.dart';
import 'package:stimmapp/app/mobile/pages/main/onboarding/reset_password_page.dart';
import 'package:stimmapp/app/mobile/scaffolds/app_bottom_bar_buttons.dart';
import 'package:stimmapp/app/mobile/widgets/button_widget.dart';
import 'package:stimmapp/app/mobile/widgets/snackbar_utils.dart';
import 'package:stimmapp/core/data/services/auth_service.dart';
import 'package:stimmapp/core/extensions/context_extensions.dart';
import 'package:stimmapp/core/theme/app_text_styles.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController controllerEm = TextEditingController(text: '');
  TextEditingController controllerPw = TextEditingController(text: '');
  String errorMessage = '';

  @override
  void dispose() {
    controllerPw.dispose();
    controllerEm.dispose();
    super.dispose();
  }

  void signIn() async {
    // Capture localized messages before the async gap.
    final successMessage = context.l10n.successfullyLoggedIn;

    try {
      await authService.value.signIn(
        email: controllerEm.text,
        password: controllerPw.text,
      );
      if (!mounted) return;
      showSuccessSnackBar(successMessage);
    } on AuthException catch (e) {
      errorMessage = e.toString();
      if (!mounted) return;
      showErrorSnackBar(errorMessage);
    }
    if (mounted) popPage();
  }

  void popPage() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: AppBottomBarButtons(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              children: [
                const SizedBox(height: 60.0),
                Text(context.l10n.signIn, style: AppTextStyles.xxlBold),
                const SizedBox(height: 20.0),
                Text('🔑', style: AppTextStyles.icons),
                const SizedBox(height: 50),
                Center(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: controllerEm,
                        decoration: InputDecoration(
                          labelText: context.l10n.email,
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
                        controller: controllerPw,
                        decoration: InputDecoration(
                          labelText: context.l10n.password,
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
                        style: AppTextStyles.m,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return ResetPasswordPage(
                                    email: controllerEm.text,
                                  );
                                },
                              ),
                            );
                          },
                          child: Text(context.l10n.resetPassword),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        buttons: [
          Builder(builder: (context) {
            return ButtonWidget(
              isFilled: true,
              label: context.l10n.signIn,
              callback: () {
                if (Form.of(context).validate()) {
                  signIn();
                }
              },
            );
          }),
        ],
      ),
    );
  }
}
