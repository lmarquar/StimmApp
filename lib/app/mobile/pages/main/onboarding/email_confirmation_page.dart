import 'package:flutter/material.dart';
import 'package:stimmapp/core/data/services/auth_service.dart';
import 'package:stimmapp/app/mobile/widgets/button_widget.dart';
import 'package:stimmapp/app/mobile/pages/main/onboarding/login_page.dart';
import 'package:stimmapp/core/extensions/context_extensions.dart';

class EmailConfirmationPage extends StatelessWidget {
  const EmailConfirmationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          context.l10n.confirmationEmailSent,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Text(
          context.l10n.confirmationEmailSentDescription,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        ButtonWidget(
          callback: () {
            authService.sendEmailVerification();
          },
          label: context.l10n.resendEmail,
        ),
        const SizedBox(height: 16),
        ButtonWidget(
          callback: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          },
          label: context.l10n.backToLogin,
        ),
      ],
    );
  }
}
