import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle, MethodChannel;
import 'package:image_picker/image_picker.dart';
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


class ReadNfcPage extends StatefulWidget {
  const ReadNfcPage({super.key});

  @override
  State<ReadNfcPage> createState() => _ReadNfcPageState();
}

class _ReadNfcPageState extends State<ReadNfcPage> {
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


  Future<void> checkNfc() async {
    final success = await platform.invokeMethod('startVerification', {'tcTokenURL': 'https://test.tc.token'});
    if (success != null) {
      showSuccessSnackBar('Verification $success');
    } else {
      showErrorSnackBar('Verification failed');
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
                  checkNfc();
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
