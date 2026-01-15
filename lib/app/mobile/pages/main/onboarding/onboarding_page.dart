import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show MethodChannel;

import 'package:stimmapp/app/mobile/scaffolds/app_bottom_bar_buttons.dart';
import 'package:stimmapp/app/mobile/widgets/button_widget.dart';
import 'package:stimmapp/app/mobile/widgets/snackbar_utils.dart';

import 'package:stimmapp/core/data/services/auth_service.dart';
import 'package:stimmapp/core/data/services/database_service.dart';

import 'package:stimmapp/core/extensions/context_extensions.dart';

import 'package:stimmapp/app/mobile/pages/main/onboarding/email_verification_page.dart';
import 'package:stimmapp/core/theme/app_text_styles.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  static const platform = MethodChannel('com.example.stimmapp/eid');
  final TextEditingController controllerPw = TextEditingController();
  final TextEditingController controllerEm = TextEditingController();

  String errorMessage = 'Error message';

  @override
  void dispose() {
    controllerPw.dispose();
    controllerEm.dispose();
    super.dispose();
  }

  void register() {
    try {
      authService.createAccount(
        email: controllerEm.text,
        password: controllerPw.text,
      );
      // After creating the account and sending verification email, navigate to EmailVerificationPage
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => EmailVerificationPage(email: controllerEm.text),
        ),
      );
    } on AuthException catch (e) {
      setState(() {
        errorMessage = '${e.code}: ${e.message ?? 'Unknown error'}';
      });
      showErrorSnackBar(errorMessage);
    } on DatabaseException catch (e) {
      setState(() {
        errorMessage =
            'Database error (${e.code}): ${e.message ?? 'Unknown error'}';
      });
      debugPrintStack(
        label: 'register database error',
        stackTrace: StackTrace.current,
      );
      showErrorSnackBar(errorMessage);
    } catch (e, st) {
      // Fallback for any other exception
      setState(() {
        errorMessage = 'Unexpected error: $e';
      });
      debugPrintStack(label: 'register error', stackTrace: st);
      showErrorSnackBar(errorMessage);
    }
  }

  Future<void> registerWithEId() async {
    var result = "defaultUser";
    var randomName = "HANA";
    if (kIsWeb) {
      showSuccessSnackBar('use your Phone for registering please');
    } else {
      final Map<dynamic, dynamic> callResult = await platform.invokeMethod(
        'passDataToNative',
        [
          {"text": "HANA"},
        ],
      );
      result = callResult['userName'] ?? "defaultUser";
      if (result == randomName) {
        showSuccessSnackBar(result);
      } else {
        showErrorSnackBar("expected: $randomName, got: $result");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Builder(
        builder: (context) {
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
                              onFieldSubmitted: (value) {
                                if (Form.of(context).validate()) {
                                  register();
                                } else {
                                  showErrorSnackBar(context.l10n.error);
                                }
                              },
                            ),
                            const SizedBox(height: 10),
                          ],
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
                  if (Form.of(context).validate()) {
                    register();
                  } else {
                    showErrorSnackBar(errorMessage);
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
