import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:stimmapp/core/extensions/context_extensions.dart';
import 'package:stimmapp/core/services/auth_service.dart';
import 'package:stimmapp/core/notifiers/notifiers.dart';
import 'package:stimmapp/app/mobile/scaffolds/app_bottom_bar_buttons.dart';
import 'package:stimmapp/app/mobile/widgets/button_widget.dart';
import 'package:stimmapp/core/services/profile_picture_service.dart';
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
  double _progress = 0.0;

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

      // Try to upload a default profile picture from assets.
      // If anything fails here we log but don't block registration.
      try {
        final user = authService.value.currentUser;
        if (user != null) {
          // Load asset bytes
          final bytes = await rootBundle.load(
            'assets/images/default_avatar.png',
          );
          final Uint8List list = bytes.buffer.asUint8List();

          // Write to a temporary file
          final tempDir = await getTemporaryDirectory();
          final tmpFile = File(
            '${tempDir.path}/default_avatar_${user.uid}.jpg',
          );
          await tmpFile.writeAsBytes(list, flush: true);

          // Upload using the service (updates Firestore and notifier internally)
          await ProfilePictureService.instance.uploadProfilePicture(
            user.uid,
            tmpFile,
            onProgress: (p) {
              if (!mounted) return;
              if ((p - _progress).abs() > 0.01) setState(() => _progress = p);
            },
          );

          // Optionally remove the temp file (non-blocking)
          try {
            await tmpFile.delete();
          } catch (_) {}
        }
      } catch (e, st) {
        // don't break registration for asset/upload failures — log for debugging
        debugPrint('Default avatar upload failed: $e\n$st');
      }

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
