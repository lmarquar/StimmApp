import 'package:flutter/material.dart';
import 'package:stimmapp/core/data/models/user_profile.dart';
import 'package:stimmapp/core/data/services/auth_service.dart';
import 'package:stimmapp/app/mobile/widgets/snackbar_utils.dart';
import 'package:stimmapp/core/extensions/context_extensions.dart';

class SignActionButton extends StatelessWidget {
  const SignActionButton({
    super.key,
    required this.label,
    required this.participantsStream,
    required this.onAction,
    required this.successMessage,
  });

  final String label;
  final Stream<List<UserProfile>> participantsStream;
  final Future<void> Function() onAction;
  final String successMessage;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<UserProfile>>(
      stream: participantsStream,
      builder: (context, snap) {
        final uid = authService.currentUser?.uid;
        final participants = snap.data ?? const [];
        final alreadySigned =
            uid != null && participants.any((p) => p.uid == uid);
        final loading = snap.connectionState == ConnectionState.waiting;
        final disabled = alreadySigned || loading;

        return ElevatedButton(
          onPressed: disabled
              ? null
              : () async {
                  final user = authService.currentUser;
                  if (user == null) {
                    if (!context.mounted) return;
                    showErrorSnackBar(context.l10n.pleaseSignInFirst);
                    return;
                  }
                  try {
                    await onAction();
                    if (!context.mounted) return;
                    showSuccessSnackBar(successMessage);
                  } catch (e) {
                    if (!context.mounted) return;
                    showErrorSnackBar(e.toString());
                  }
                },
          child: Text(alreadySigned ? '$label ✓' : label),
        );
      },
    );
  }
}
