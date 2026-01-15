import 'package:flutter/material.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:stimmapp/app/mobile/scaffolds/app_bottom_bar_buttons.dart';
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
                const SizedBox(height: 20.0),
                const Text('✏️', style: AppTextStyles.icons),
                const SizedBox(height: 50),
                Form(
                  key: _formKey,
                  child: Center(
                    child: Column(
                      children: [
                        GooglePlaceAutoCompleteTextField(
                          textEditingController: _controllerAddress,
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
                            _controllerAddress.text =
                                prediction.description ?? "";
                            _controllerAddress.selection =
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
          label: context.l10n.confirm,
          callback: () async {
            if (_formKey.currentState!.validate()) {
              final successMessage = context.l10n.addressUpdatedSuccessfully;
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
