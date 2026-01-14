import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:stimmapp/app/mobile/pages/main/home/widget_tree.dart';

class SetUserDetailsPage extends StatefulWidget {
  const SetUserDetailsPage({super.key});

  @override
  State<SetUserDetailsPage> createState() => _SetUserDetailsPageState();
}

class _SetUserDetailsPageState extends State<SetUserDetailsPage> {
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
    controllerSurname.dispose();
    controllerGivenName.dispose();
    controllerDateOfBirth.dispose();
    controllerAddress.dispose();
    super.dispose();
  }

  void saveProfile() async {
    try {
      if (controllerAddress.text.trim().isEmpty) {
        showErrorSnackBar('Please enter your address');
        return;
      }

      if (_selectedState == null) {
        showErrorSnackBar('Please select a state');
        return;
      }

      final user = authService.currentUser;

      if (user != null) {
        final uid = user.uid;

        final profile = UserProfile(
          uid: uid,
          email: user.email,
          displayName: user.displayName,
          state: _selectedState,
          createdAt: DateTime.now(),
          surname: controllerSurname.text,
          givenName: controllerGivenName.text,
          dateOfBirth: _selectedDateOfBirth,
          address: controllerAddress.text,
        );

        await UserRepository.create().upsert(profile);
      }

      AppData.isAuthConnected.value = true;

      try {
        final user = authService.currentUser;
        if (user != null) {
          final bytes = await rootBundle.load(
            'assets/images/default_avatar.png',
          );
          final Uint8List list = bytes.buffer.asUint8List();

          final xFile = XFile.fromData(
            list,
            name: 'default_avatar.png',
            mimeType: 'image/png',
          );

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
        debugPrint('Default avatar upload failed: $e\n$st');
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const WidgetTree(),
        ),
      );
    } on DatabaseException catch (e) {
      setState(() {
        errorMessage =
            'Database error (${e.code}): ${e.message ?? 'Unknown error'}';
      });
      debugPrintStack(
        label: 'save profile database error',
        stackTrace: StackTrace.current,
      );
      showErrorSnackBar(errorMessage);
    } catch (e, st) {
      setState(() {
        errorMessage = 'Unexpected error: $e';
      });
      debugPrintStack(label: 'save profile error', stackTrace: st);
      showErrorSnackBar(errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Builder(
        builder: (context) {
          return AppBottomBarButtons(
            appBar: AppBar(title: Text("Set your details")),
            body: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('📝', style: TextStyle(fontSize: 50)),
                      const SizedBox(height: 50),
                      Center(
                        child: Column(
                          children: [
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
                            TextFormField(
                              controller: controllerAddress,
                              decoration: InputDecoration(
                                labelText: context.l10n.address,
                              ),
                              validator: (String? value) {
                                if (value == null || value.trim().isEmpty) {
                                  return context.l10n.enterSomething;
                                }
                                return null;
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
                label: "Save",
                callback: () {
                  if (Form.of(context).validate()) {
                    saveProfile();
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
