import 'package:flutter/material.dart';
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
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.petitionDetails)),
      body: StreamBuilder<Petition?>(
        stream: repo.watch(id),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final p = snap.data;
          if (p == null) return Center(child: Text(context.l10n.notFound));
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(p.description),
                const SizedBox(height: 16),
                Text('Signatures: ${p.signatureCount}'),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final user = authService.value.currentUser;
                      if (user == null) {
                        showErrorSnackBar(context.l10n.pleaseSignInFirst);
                        return;
                      }
                      showSuccessSnackBar(context.l10n.signed);
                      await repo.sign(p.id, user.uid);
                    },
                    child: const Text('Sign'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
