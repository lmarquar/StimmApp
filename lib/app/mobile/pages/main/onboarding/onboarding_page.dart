import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle, MethodChannel;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:stimmapp/app/mobile/scaffolds/app_bottom_bar_buttons.dart';
import 'package:stimmapp/app/mobile/widgets/button_widget.dart';
import 'package:stimmapp/app/mobile/widgets/select_address_widget.dart';
import 'package:stimmapp/app/mobile/widgets/snackbar_utils.dart';
import 'package:stimmapp/core/data/models/user_profile.dart';
import 'package:stimmapp/core/data/repositories/user_repository.dart';
import 'package:stimmapp/core/data/services/auth_service.dart';
import 'package:stimmapp/core/data/services/database_service.dart';
import 'package:stimmapp/core/data/services/profile_picture_service.dart';
import 'package:stimmapp/core/extensions/context_extensions.dart';
import 'package:stimmapp/core/notifiers/notifiers.dart';
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
  final TextEditingController controllerSurname = TextEditingController();
  final TextEditingController controllerGivenName = TextEditingController();
  final TextEditingController controllerDateOfBirth = TextEditingController();
  final TextEditingController controllerAddress = TextEditingController();
  DateTime? _selectedDateOfBirth;

  String errorMessage = 'Error message';
  double _progress = 0.0;
  String? _selectedState;

  @override
  void dispose() {
    controllerPw.dispose();
    controllerEm.dispose();
    controllerSurname.dispose();
    controllerGivenName.dispose();
    controllerDateOfBirth.dispose();
    controllerAddress.dispose();
    super.dispose();
  }

  void register() async {
    try {
      if (controllerAddress.text.trim().isEmpty) {
        showErrorSnackBar('Please enter your address');
        return;
      }

      if (_selectedState == null) {
        showErrorSnackBar('Please select a state');
        return;
      }

      final cred = await authService.createAccount(
        email: controllerEm.text,
        password: controllerPw.text,
      );
      await authService.updateUsername(
        username: controllerEm.text.split('@')[0],
      );

      // Small delay to ensure Auth state is recognized by Firestore/Storage

      if (cred.user != null) {
        final uid = cred.user!.uid;

        final profile = UserProfile(
          uid: uid,
          email: cred.user!.email,
          displayName: authService.currentUser!.displayName,
          state: _selectedState,
          createdAt: DateTime.now(),
          surname: controllerSurname.text,
          givenName: controllerGivenName.text,
          dateOfBirth: _selectedDateOfBirth,
          address: controllerAddress.text,
          // Leaving other fields empty for now as requested
        );

        await UserRepository.create().upsert(profile);
      }

      AppData.isAuthConnected.value = true;

      // Try to upload a default profile picture from assets.
      // If anything fails here we log but don't block registration.
      try {
        final user = authService.currentUser;
        if (user != null) {
          // Load asset bytes
          final bytes = await rootBundle.load(
            'assets/images/default_avatar.png',
          );
          final Uint8List list = bytes.buffer.asUint8List();

          final xFile = XFile.fromData(
            list,
            name: 'default_avatar.png',
            mimeType: 'image/png',
          );

          // Upload using the service (updates Firestore and notifier internally)
          await ProfilePictureService.instance.uploadProfilePicture(
            user.uid,
            xFile,
            onProgress: (p) {
              if (!mounted) return;
              if ((p - _progress).abs() > 0.01) setState(() => _progress = p);
            },
          );
        }
      } catch (e, st) {
        // don't break registration for asset/upload failures — log for debugging
        debugPrint('Default avatar upload failed: $e\n$st');
      }

      popPage();
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

  void popPage() {
    Navigator.pop(context);
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
                            TextFormField(
                              controller: controllerSurname,
                              decoration: InputDecoration(
                                labelText: context.l10n.surname,
                              ),
                              validator: (String? value) {
                                if (value == null || value.trim().isEmpty) {
                                  return context.l10n.enterSomething;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: controllerGivenName,
                              decoration: InputDecoration(
                                labelText: context.l10n.givenName,
                              ),
                              validator: (String? value) {
                                if (value == null || value.trim().isEmpty) {
                                  return context.l10n.enterSomething;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: controllerDateOfBirth,
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: context.l10n.dateOfBirth,
                                suffixIcon: const Icon(Icons.calendar_today),
                              ),
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime(2000),
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime.now(),
                                );
                                if (date != null) {
                                  setState(() {
                                    _selectedDateOfBirth = date;
                                    controllerDateOfBirth.text = DateFormat(
                                      'yyyy-MM-dd',
                                    ).format(date);
                                  });
                                }
                              },
                              validator: (String? value) {
                                if (_selectedDateOfBirth == null) {
                                  return context.l10n.enterSomething;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 10),

                            SelectAddressWidget(
                              selectedState: _selectedState,
                              onStateChanged: (newValue) {
                                setState(() {
                                  _selectedState = newValue;
                                });
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
