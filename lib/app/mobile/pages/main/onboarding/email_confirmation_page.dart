import 'package:flutter/material.dart';
import 'package:stimmapp/core/data/services/auth_service.dart';
import 'package:stimmapp/app/mobile/widgets/buttons.dart';
import 'package:stimmapp/app/mobile/widgets/page_wrapper.dart';
import 'package:stimmapp/app/mobile/pages/main/onboarding/login_page.dart';

class EmailConfirmationPage extends StatelessWidget {
  const EmailConfirmationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      isCard: true,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Confirmation Email Sent',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          const Text(
            'We have sent a confirmation email to your email address. Please check your inbox and follow the instructions to complete your registration.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          PrimaryButton(
            onPressed: () {
              authService.sendEmailVerification();
            },
            child: const Text('Resend Email'),
          ),
          const SizedBox(height: 16),
          SecondaryButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginPage(),
                ),
              );
            },
            child: const Text('Back to Login'),
          ),
        ],
      ),
    );
  }
}