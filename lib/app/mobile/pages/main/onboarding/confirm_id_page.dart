import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle, MethodChannel;
import 'package:image_picker/image_picker.dart';
import 'package:stimmapp/app/mobile/pages/main/onboarding/read_nfc_page.dart';
import 'package:stimmapp/core/data/services/auth_service.dart';
import 'package:stimmapp/core/data/services/profile_picture_service.dart';
import 'package:stimmapp/core/extensions/context_extensions.dart';
import 'package:stimmapp/core/notifiers/notifiers.dart';
import 'package:stimmapp/app/mobile/scaffolds/app_bottom_bar_buttons.dart';
import 'package:stimmapp/app/mobile/widgets/button_widget.dart';
import 'package:stimmapp/app/mobile/widgets/snackbar_utils.dart';
import 'package:stimmapp/core/data/models/user_profile.dart';
import 'package:stimmapp/core/data/repositories/user_repository.dart';
import 'package:stimmapp/core/theme/app_text_styles.dart';
import 'package:flutter/foundation.dart' show kIsWeb;


class ConfirmIdPage extends StatefulWidget {
  const ConfirmIdPage({super.key});

  @override
  State<ConfirmIdPage> createState() => _ConfirmIdPageState();
}

class _ConfirmIdPageState extends State<ConfirmIdPage> {
  final TextEditingController controllerPw = TextEditingController();
  final TextEditingController controllerEm = TextEditingController();
  static const platform = MethodChannel('com.example.stimmapp/eid');
  String errorMessage = 'Error message';
  String _lastSdkMessage = 'No message yet';
  double _progress = 0.0;
  String? _selectedState;

  @override
  void initState() {
    super.initState();
    platform.setMethodCallHandler((call) async {
      debugPrint('Received method call from native: ${call.method} with args: ${call.arguments}');
      switch (call.method) {
        case 'onMessage':
          setState(() {
            _lastSdkMessage = call.arguments as String;
          });
          break;
        case 'onRequestPin':
          _showPinDialog();
          break;
        case 'onCardDetected':
          showSuccessSnackBar('ID Card detected!');
          break;
        case 'onCardLost':
          showErrorSnackBar('ID Card lost!');
          break;
      }
    });
  }

  void _showPinDialog() {
    final TextEditingController pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter PIN'),
        content: TextField(
          controller: pinController,
          decoration: const InputDecoration(hintText: 'PIN'),
          keyboardType: TextInputType.number,
          obscureText: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              platform.invokeMethod('setPin', {'pin': pinController.text});
              Navigator.pop(context);
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void register() async {
    try {
      final cred = await authService.value.createAccount(
        email: controllerEm.text,
        password: controllerPw.text,
      );
      await authService.value.updateUsername(
        username: controllerEm.text.split('@')[0],
      );

      if (cred.user != null) {
        final profile = UserProfile(
          uid: cred.user!.uid,
          email: cred.user!.email,
          displayName: authService.value.currentUser!.displayName,
          state: _selectedState,
          createdAt: DateTime.now(),
        );
        await UserRepository.create().upsert(profile);
      }

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

  Future<void> startVerification() async {
      final success = await platform.invokeMethod('startVerification', {'tcTokenURL': 'https://test.tc.token'});
      if (success != null) {
        showSuccessSnackBar('Verification $success');
      } else {
        showErrorSnackBar('Verification failed');
      }
  }

  Future<void> getInfo() async {
      await platform.invokeMethod('getInfo');
  }

  Future<void> testKotlinCall() async {
    var result = "defaultUser";
    var randomName = "HANA";
    if (kIsWeb) {
      showErrorSnackBar('use your Phone for registering please');
    } else {
      final Map<dynamic, dynamic> callResult = await platform.invokeMethod('passDataToNative', [
        {"text": "HANA"}
      ]);
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
            appBar: AppBar(title: Text("confirm ID here")),
            body: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('ᯤ', style: AppTextStyles.icons),
                      const SizedBox(height: 50),
                      Center(
                        child: Column(
                          children: [
                            ButtonWidget(
                              isFilled: false,
                              label: "test Kotlin",
                              callback: () {
                                if (Form.of(context).validate()) {
                                  testKotlinCall();
                                } else {
                                  showErrorSnackBar(errorMessage);
                                }
                              },
                            ),
                            const SizedBox(height: 10),
                            ButtonWidget(
                              isFilled: false,
                              label: "easiest AusweisApp API call",
                              callback: () {
                                if (Form.of(context).validate()) {
                                  getInfo();
                                } else {
                                  showErrorSnackBar(errorMessage);
                                }
                              },
                            ),
                            const SizedBox(height: 20),
                            ButtonWidget(
                              isFilled: false,
                              label: "NFC Reader",
                              callback: () {
                                if (Form.of(context).validate()) {
                                  Navigator.push( context,
                                    MaterialPageRoute(builder: (context) => const ReadNfcPage()),);
                                } else {
                                  showErrorSnackBar(errorMessage);
                                }
                              },
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "Last SDK Message:",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              _lastSdkMessage,
                              style: TextStyle(fontSize: 12),
                            ),
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
                  startVerification();
                },
              ),
              const SizedBox(height: 10),
            ],
          );
        },
      ),
    );
  }
}
