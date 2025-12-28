import 'package:flutter/material.dart';
import 'package:stimmapp/app/mobile/scaffolds/app_bottom_bar_buttons.dart';
import 'package:stimmapp/app/mobile/widgets/button_widget.dart';
import 'package:stimmapp/app/mobile/widgets/select_adress_widget.dart';
import 'package:stimmapp/app/mobile/widgets/snackbar_utils.dart';
import 'package:stimmapp/core/data/repositories/user_repository.dart';
import 'package:stimmapp/core/extensions/context_extensions.dart';
import 'package:stimmapp/core/functions/update_state.dart';
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
  String errorMessage = '';
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    final userProfile = await UserRepository.currentUser();
    if (userProfile != null) {
      setState(() {
        _selectedState = userProfile.state;
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
              try {
                updateState(_selectedState!);
              } catch (e) {
                showErrorSnackBar(e.toString());
                return;
              }
              showSuccessSnackBar(context.l10n.stateUpdatedSuccessfully);
            }
          },
        ),
      ],
    );
  }
}
