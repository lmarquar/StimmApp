import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stimmapp/app/mobile/widgets/button_widget.dart';
import 'package:stimmapp/app/mobile/widgets/snackbar_utils.dart';
import 'package:stimmapp/core/data/services/auth_service.dart';
import 'package:stimmapp/core/extensions/context_extensions.dart';
import 'package:stimmapp/app/mobile/pages/main/set_user_details/set_user_details_page.dart'; // Assuming this will be the next step

class EmailVerificationPage extends StatefulWidget {
  final String email;

  const EmailVerificationPage({super.key, required this.email});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  Timer? _timer;
  bool _isEmailVerified = false;
  bool _canResendEmail = true; // To prevent spamming resend button

  @override
  void initState() {
    super.initState();
    _checkEmailVerificationStatus();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkEmailVerificationStatus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkEmailVerificationStatus() async {
    // Reload user to get the latest email verification status
    await FirebaseAuth.instance.currentUser?.reload();
    if (!mounted) return;
    setState(() {
      _isEmailVerified =
          FirebaseAuth.instance.currentUser?.emailVerified ?? false;
    });

    if (_isEmailVerified) {
      _timer?.cancel();
      // Navigate to SetUserDetailsPage or home if already verified
      _navigateToNextScreen();
    }
  }

  void _navigateToNextScreen() {
    // This assumes that after email verification, the next step is to set user details
    // The main app flow will then check if the user profile exists in Firestore
    // and navigate to SetUserDetailsPage if it doesn't.
    // For now, we'll just pop back or navigate to a placeholder for the next step.
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const SetUserDetailsPage()),
        (route) => false, // Remove all previous routes
      );
    }
  }

  Future<void> _sendVerificationEmail() async {
    if (!_canResendEmail) return;

    // Capture localized strings before async gap
    final successMsg = context.l10n.verificationEmailSent;
    final errorPrefix = context.l10n.errorSendingEmail;

    try {
      setState(() {
        _canResendEmail = false;
      });
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      if (!mounted) return;
      showSuccessSnackBar(successMsg);
      Future.delayed(const Duration(seconds: 30), () {
        if (!mounted) return;
        setState(() {
          _canResendEmail = true;
        });
      });
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      showErrorSnackBar('$errorPrefix: ${e.message}');
    } catch (e) {
      if (!mounted) return;
      showErrorSnackBar('$errorPrefix: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.emailVerification)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              context.l10n.verificationEmailSentTo(widget.email),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            Text(
              context.l10n.pleaseCheckYourInbox,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            if (!_isEmailVerified)
              ButtonWidget(
                label: _canResendEmail
                    ? context.l10n.resendVerificationEmail
                    : context.l10n.resendEmailCooldown,
                callback: _canResendEmail ? _sendVerificationEmail : null,
                isFilled: true,
              ),
            const SizedBox(height: 20),
            ButtonWidget(
              label: context.l10n.continueText,
              callback: _isEmailVerified ? _navigateToNextScreen : null,
            ),
            const SizedBox(height: 20),
            ButtonWidget(
              label: context.l10n.cancelRegistration,
              callback: () async {
                await AuthService().firebaseAuth.currentUser?.delete();
                await AuthService().signOut();
                if (!context.mounted) return;
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        ),
      ),
    );
  }
}
