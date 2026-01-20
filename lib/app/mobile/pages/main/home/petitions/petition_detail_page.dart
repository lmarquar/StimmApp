import 'package:flutter/material.dart';
import 'package:stimmapp/app/mobile/pages/others/base_detail_page.dart';
import 'package:stimmapp/core/data/models/petition.dart';
import 'package:stimmapp/core/data/repositories/petition_repository.dart';
import 'package:stimmapp/core/data/services/auth_service.dart';
import 'package:stimmapp/core/extensions/context_extensions.dart';
import 'package:stimmapp/app/mobile/widgets/sign_action_button.dart';

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
      contentBuilder: (context, p) {
        if (p.imageUrl != null) {
          return Image.network(p.imageUrl!);
        }
        return const SizedBox.shrink();
      },
      bottomAction: SignActionButton(
        label: context.l10n.sign,
        participantsStream: repo.watchParticipants(id),
        onAction: () async {
          final user = authService.currentUser!;
          await repo.sign(id, user.uid);
        },
        successMessage: context.l10n.signed,
      ),
    );
  }
}
