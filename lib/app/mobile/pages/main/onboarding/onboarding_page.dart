import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stimmapp/core/extensions/context_extensions.dart';
import 'package:stimmapp/core/firebase/auth_service.dart';
import 'package:stimmapp/core/notifiers/notifiers.dart';
import 'package:stimmapp/app/mobile/scaffolds/app_bottom_bar_buttons.dart';
import 'package:stimmapp/app/mobile/widgets/button_widget.dart';
import 'package:stimmapp/core/theme/app_text_styles.dart';

TextEditingController controllerPw = TextEditingController();
TextEditingController controllerEm = TextEditingController();

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _formKey = GlobalKey<FormState>();
  String errorMessage = 'Error message';

  void register() async {
    try {
      await authService.value.createAccount(
        email: controllerEm.text,
        password: controllerPw.text,
      );
      await authService.value.updateUsername(
        username: controllerEm.text.split('@')[0],
      );
      AppData.isAuthConnected.value = true;
      popPage();
    } on FirebaseAuthException catch (e) {
      // e.code contains the Firebase error code (e.g. 'invalid-email', 'weak-password')
      setState(() {
        errorMessage = '${e.code}: ${e.message ?? 'Unknown error'}';
      });
    } catch (e, st) {
      // Fallback for any other exception
      setState(() {
        errorMessage = 'Unexpected error: $e';
      });
      // Optional: print stack trace to help debugging
      debugPrintStack(label: 'register error', stackTrace: st);
    }
  }

  void popPage() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomBarButtons(
      appBar: AppBar(title: Text("register here")),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🔑', style: AppTextStyles.icons),
                const SizedBox(height: 50),
                Form(
                  key: _formKey,
                  child: Center(
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
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
      buttons: [
        ButtonWidget(
          isFilled: true,
          label: context.l10n.register,
          callback: () {
            if (_formKey.currentState!.validate()) {
              register();
            }
          },
        ),
      ],
    );
  }
}
