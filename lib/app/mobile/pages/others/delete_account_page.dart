import 'package:flutter/material.dart';
import 'package:stimmapp/app/mobile/scaffolds/app_bottom_bar_buttons.dart';
import 'package:stimmapp/app/mobile/widgets/button_widget.dart';
import 'package:stimmapp/app/mobile/widgets/snackbar_utils.dart';
import 'package:stimmapp/core/extensions/context_extensions.dart';
import 'package:stimmapp/core/firebase/auth_service.dart';
import 'package:stimmapp/core/theme/app_text_styles.dart';

import '../../../../core/notifiers/notifiers.dart';

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  final formKey = GlobalKey<FormState>();
  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerPassword = TextEditingController();
  String errorMessage = '';

  void popUntilLast() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void deleteAccount() async {
    try {
      await authService.value.deleteAccount(
        email: controllerEmail.text,
        password: controllerPassword.text,
      );
      AppData.isAuthConnected.value = false;
      AppData.navBarCurrentIndexNotifier.value = 0;
      AppData.onboardingCurrentIndexNotifier.value = 0;
      showSnackBar();
      popUntilLast();
    } catch (e) {
      showErrorSnackBar(e.toString());
    }
  }

  void showSnackBar() {
    ScaffoldMessenger.of(context).clearMaterialBanners();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        content: Text(context.l10n.deleted, style: AppTextStyles.m),
        showCloseIcon: true,
      ),
    );
  }

  @override
  void dispose() {
    controllerEmail.dispose();
    controllerPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomBarButtons(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: [
              const SizedBox(height: 60.0),
              Text(context.l10n.deleteMyAccount, style: AppTextStyles.xxlBold),
              const SizedBox(height: 20.0),
              const Text('❌', style: AppTextStyles.icons),
              const SizedBox(height: 50),
              Form(
                key: formKey,
                child: Center(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: controllerEmail,
                        decoration: InputDecoration(
                          labelText: context.l10n.enterYourEmail,
                        ),
                        validator: (String? value) {
                          if (value == null) {
                            return context.l10n.enterSomething;
                          }
                          if (value.trim().isEmpty) {
                            return context.l10n.enterSomething;
                          }
                          if (controllerEmail.text.contains('@') == false) {
                            return context.l10n.invalidEmailEntered;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: controllerPassword,
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
                      Text(
                        errorMessage,
                        style: AppTextStyles.m.copyWith(
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      buttons: [
        ButtonWidget(
          label: context.l10n.deletePermanently,
          isFilled: true,
          callback: () {
            if (formKey.currentState!.validate()) {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text(context.l10n.finalNotice),
                    content: Text(
                      context
                          .l10n
                          .areYouSureYouWantToDeleteYourAccountThisActionIsIrreversible,
                      style: AppTextStyles.m,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () async {
                          popUntilLast();
                          deleteAccount();
                        },
                        child: Text(context.l10n.deletePermanently),
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
            }
          },
        ),
      ],
    );
  }
}
