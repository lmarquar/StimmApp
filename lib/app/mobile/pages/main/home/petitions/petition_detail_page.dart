import 'package:flutter/material.dart';
import 'package:stimmapp/app/mobile/widgets/base_detail_page.dart';
import 'package:stimmapp/app/mobile/widgets/snackbar_utils.dart';
import 'package:stimmapp/core/data/models/petition.dart';
import 'package:stimmapp/core/data/repositories/petition_repository.dart';
import 'package:stimmapp/core/data/services/auth_service.dart';
import 'package:stimmapp/core/extensions/context_extensions.dart';

class PetitionDetailPage extends StatelessWidget {
  const PetitionDetailPage({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    final repo = PetitionRepository.create();
    return BaseDetailPage<Petition>(
      id: id,
      appBarTitle: context.l10n.petitionDetails,
      streamProvider: repo.watch,
      participantsStream: repo.watchParticipants(id),
      contentBuilder: (context, p) => const SizedBox.shrink(),
      bottomAction: ElevatedButton(
        onPressed: () async {
          final user = authService.currentUser;
          if (user == null) {
            showErrorSnackBar(context.l10n.pleaseSignInFirst);
            return;
          }
          showSuccessSnackBar(context.l10n.signed);
          await repo.sign(id, user.uid);
        },
        child: Text(context.l10n.sign),
      ),
    );
  }
}
