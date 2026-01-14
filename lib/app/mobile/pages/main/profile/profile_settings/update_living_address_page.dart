import 'package:flutter/material.dart';
import 'package:stimmapp/app/mobile/scaffolds/app_bottom_bar_buttons.dart';
import 'package:stimmapp/app/mobile/widgets/address_autocomplete_field.dart';
import 'package:stimmapp/app/mobile/widgets/button_widget.dart';
import 'package:stimmapp/app/mobile/widgets/select_address_widget.dart';
import 'package:stimmapp/app/mobile/widgets/snackbar_utils.dart';
import 'package:stimmapp/core/data/firebase/firebase_options.dart';
import 'package:stimmapp/core/data/models/user_profile.dart';
import 'package:stimmapp/core/data/repositories/user_repository.dart';
import 'package:stimmapp/core/data/services/auth_service.dart';
import 'package:stimmapp/core/extensions/context_extensions.dart';
import 'package:stimmapp/core/theme/app_text_styles.dart';

class UpdateLivingAddressPage extends StatefulWidget {
  const UpdateLivingAddressPage({super.key});

  @override
  State<UpdateLivingAddressPage> createState() =>
      _UpdateLivingAddressPageState();
}

class _UpdateLivingAddressPageState extends State<UpdateLivingAddressPage>
    with WidgetsBindingObserver {
  String? _selectedState;
  final TextEditingController _controllerAddress = TextEditingController();
  String errorMessage = '';
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadInitialState();
  }

  @override
  void dispose() {
    _controllerAddress.dispose();
    super.dispose();
  }

  Future<void> _loadInitialState() async {
    final userProfile = await UserRepository.currentUser();
    if (userProfile != null) {
      setState(() {
        _selectedState = userProfile.state;
        _controllerAddress.text = userProfile.address ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomBarButtons(
      appBar: AppBar(title: Text(context.l10n.updateLivingAddress)),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 60.0),
                Text(
                  context.l10n.entryNotYetImplemented,
                  style: AppTextStyles.xxlBold,
                ),
                const SizedBox(height: 20.0),
                const Text('✏️', style: AppTextStyles.icons),
                const SizedBox(height: 50),
                Form(
                  key: _formKey,
                  child: Center(
                    child: Column(
                      children: [
                        AddressAutocompleteField(
                          controller: _controllerAddress,
                          apiKey: DefaultFirebaseOptions.currentPlatform.apiKey,
                          label: context.l10n.address,
                          validator: (String? value) {
                            if (value == null || value.trim().isEmpty) {
                              return context.l10n.enterSomething;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        SelectAddressWidget(
                          selectedState: _selectedState,
                          onStateChanged: (newValue) {
                            setState(() {
                              _selectedState = newValue;
                            });
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
      ),
      buttons: [
        ButtonWidget(
          isFilled: true,
          label: context.l10n.updateState,
          callback: () async {
            if (_formKey.currentState!.validate()) {
              final successMessage = context.l10n.stateUpdatedSuccessfully;
              try {
                final userRepository = UserRepository.create();
                final uid = authService.currentUser!.uid;
                final userProfile = await userRepository.getById(uid);
                final updatedProfile = (userProfile ?? UserProfile(uid: uid))
                    .copyWith(
                      state: _selectedState,
                      address: _controllerAddress.text,
                    );
                await userRepository.upsert(updatedProfile);
              } catch (e) {
                showErrorSnackBar(e.toString());
                return;
              }
              showSuccessSnackBar(successMessage);
            }
          },
        ),
      ],
    );
  }
}
