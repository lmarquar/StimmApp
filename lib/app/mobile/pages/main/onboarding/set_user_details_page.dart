import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:stimmapp/app/mobile/pages/main/home/widget_tree.dart';
import 'package:stimmapp/app/mobile/scaffolds/app_bottom_bar_buttons.dart';
import 'package:stimmapp/app/mobile/widgets/button_widget.dart';
import 'package:stimmapp/app/mobile/widgets/select_address_widget.dart';
import 'package:stimmapp/app/mobile/widgets/snackbar_utils.dart';
import 'package:stimmapp/core/data/firebase/firebase_options.dart';
import 'package:stimmapp/core/data/models/user_profile.dart';
import 'package:stimmapp/core/data/repositories/user_repository.dart';
import 'package:stimmapp/core/data/services/auth_service.dart';
import 'package:stimmapp/core/data/services/database_service.dart';
import 'package:stimmapp/core/data/services/profile_picture_service.dart';
import 'package:stimmapp/core/extensions/context_extensions.dart';
import 'package:stimmapp/core/notifiers/notifiers.dart';
import 'package:stimmapp/core/theme/app_text_styles.dart';

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
  String? _selectedState;
  String errorMessage = 'Error message';
  double _progress = 0.0;

  @override
  void dispose() {
    controllerSurname.dispose();
    controllerGivenName.dispose();
    controllerDateOfBirth.dispose();
    controllerAddress.dispose();
    super.dispose();
  }

  Future<void> _saveUserDetails() async {
    try {
      final User? currentUser = authService.currentUser;

      if (currentUser == null) {
        showErrorSnackBar('No authenticated user found.');
        return;
      }

      if (controllerAddress.text.trim().isEmpty) {
        showErrorSnackBar('Please enter your address');
        return;
      }

      if (_selectedState == null) {
        showErrorSnackBar('Please select a state');
        return;
      }

      // Update username (display name) - using email part as default
      await authService.updateUsername(
        username: currentUser.email?.split('@')[0] ?? 'New User',
      );

      final profile = UserProfile(
        uid: currentUser.uid,
        email: currentUser.email,
        displayName: authService.currentUser!.displayName,
        state: _selectedState,
        createdAt: DateTime.now(),
        surname: controllerSurname.text,
        givenName: controllerGivenName.text,
        dateOfBirth: _selectedDateOfBirth,
        address: controllerAddress.text,
      );

      await UserRepository.create().upsert(profile);

      AppData.isAuthConnected.value = true; // Signal that auth is connected

      // Try to upload a default profile picture from assets.
      try {
        // Load asset bytes
        final bytes = await rootBundle.load('assets/images/default_avatar.png');
        final Uint8List list = bytes.buffer.asUint8List();

        final xFile = XFile.fromData(
          list,
          name: 'default_avatar.png',
          mimeType: 'image/png',
        );

        // Upload using the service (updates Firestore and notifier internally)
        await ProfilePictureService.instance.uploadProfilePicture(
          currentUser.uid,
          xFile,
          onProgress: (p) {
            if (!mounted) return;
            if ((p - _progress).abs() > 0.01) setState(() => _progress = p);
          },
        );
      } catch (e, st) {
        // don't block registration for asset/upload failures — log for debugging
        debugPrint('Default avatar upload failed: $e\n$st');
      }

      // Navigate to main app screen after user details are set
      if (mounted) {
        // Replace with your actual main app route
        // Example: Navigator.of(context).pushAndRemoveUntil(
        //   MaterialPageRoute(builder: (context) => const MainAppScreen()),
        //   (route) => false,
        // );
        // For now, pop to remove this page, assuming the calling context handles further navigation
        Navigator.of(context).pop();
      }
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
        label: 'saveUserDetails database error',
        stackTrace: StackTrace.current,
      );
      showErrorSnackBar(errorMessage);
    } catch (e, st) {
      setState(() {
        errorMessage = 'Unexpected error: $e';
      });
      debugPrintStack(label: 'saveUserDetails error', stackTrace: st);
      showErrorSnackBar(errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Builder(
        builder: (context) {
          return AppBottomBarButtons(
            appBar: AppBar(title: Text(context.l10n.setUserDetails)),
            body: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                        if (!mounted) return;
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
                    GooglePlaceAutoCompleteTextField(
                      textEditingController: controllerAddress,
                      googleAPIKey:
                          DefaultFirebaseOptions.currentPlatform.apiKey,
                      inputDecoration: InputDecoration(
                        labelText: context.l10n.address,
                        border: const OutlineInputBorder(),
                      ),
                      countries: const ["de"],
                      isLatLngRequired: true,
                      getPlaceDetailWithLatLng: (Prediction prediction) {},
                      debounceTime: 600,
                      itemClick: (Prediction prediction) {
                        controllerAddress.text = prediction.description ?? "";
                        controllerAddress.selection =
                            TextSelection.fromPosition(
                              TextPosition(
                                offset: prediction.description?.length ?? 0,
                              ),
                            );
                      },
                      itemBuilder: (context, index, prediction) {
                        return Container(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on),
                              const SizedBox(width: 7),
                              Expanded(
                                child: Text(
                                  prediction.description ?? "",
                                  style: AppTextStyles.m,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      seperatedBuilder: const Divider(),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            buttons: [
              ButtonWidget(
                isFilled: true,
                label: context.l10n.save,
                callback: () {
                  if (controllerAddress.text.trim().isEmpty) {
                    showErrorSnackBar(context.l10n.enterSomething);
                    return;
                  }
                  if (!Form.of(context).validate()) {
                    showErrorSnackBar(errorMessage);
                  } else {
                    _saveUserDetails();
                    if (mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const WidgetTree(),
                        ),
                        (route) => false,
                      );
                    }
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
