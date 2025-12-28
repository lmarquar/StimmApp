import 'package:flutter/material.dart';
import 'package:stimmapp/app/mobile/scaffolds/app_bottom_bar_buttons.dart';
import 'package:stimmapp/app/mobile/widgets/button_widget.dart';
import 'package:stimmapp/app/mobile/widgets/snackbar_utils.dart';
import 'package:stimmapp/core/data/services/database_service.dart';
import 'package:stimmapp/core/extensions/context_extensions.dart';
import 'package:stimmapp/core/functions/update_user_name.dart';
import 'package:stimmapp/core/theme/app_text_styles.dart';

class UpdateUsernamePage extends StatefulWidget {
  const UpdateUsernamePage({super.key});

  @override
  State<UpdateUsernamePage> createState() => _UpdateUsernamePageState();
}

class _UpdateUsernamePageState extends State<UpdateUsernamePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController controllerUsername = TextEditingController();

  String errorMessage = '';
  @override
  void dispose() {
    controllerUsername.dispose();
    super.dispose();
  }

  void changeUsername() async {
    final username = controllerUsername.text;
    final successMessage = context.l10n.usernameChangedSuccessfully;
    try {
      await updateUsername(username);

      if (!mounted) return;
      showSuccessSnackBar(successMessage);
    } catch (e) {
      if (!mounted) return;
      if (e is DatabaseException) {
        showErrorSnackBar(e.message ?? 'Unknown error');
        return;
      }
      showErrorSnackBar(context.l10n.usernameChangeFailed + e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomBarButtons(
      appBar: AppBar(title: Text(context.l10n.updateUsername)),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 60.0),
                Text(context.l10n.updateUsername, style: AppTextStyles.xxlBold),
                const SizedBox(height: 20.0),
                const Text('✏️', style: AppTextStyles.icons),
                const SizedBox(height: 50),
                Form(
                  key: _formKey,
                  child: Center(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: controllerUsername,
                          decoration: InputDecoration(
                            labelText: context.l10n.newUsername,
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
          label: context.l10n.updateUsername,
          callback: () async {
            if (_formKey.currentState!.validate()) {
              changeUsername();
            }
          },
        ),
      ],
    );
  }
}
