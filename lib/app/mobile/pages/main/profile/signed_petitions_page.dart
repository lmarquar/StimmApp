import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stimmapp/core/data/repositories/petition_repository.dart';
import 'package:stimmapp/core/data/services/auth_service.dart';
import 'package:stimmapp/core/extensions/context_extensions.dart';

class SignedPetitionsPage extends StatelessWidget {
  const SignedPetitionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = authService.currentUser;

    if (user == null) {
      return Scaffold(
        body: Center(child: Text(context.l10n.pleaseSignInFirst)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.signedPetitions)),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: PetitionRepository.create().watchSignedPetitions(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(context.l10n.error));
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(child: Text(context.l10n.notFound));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, _) => const Divider(),
            itemBuilder: (context, index) {
              final data = docs[index].data();

              final String petitionID = data['petitionID'] as String;
              final Timestamp signedAtTimestamp = data['signedAt'] as Timestamp;
              final DateTime signedAt = signedAtTimestamp.toDate();

              return ListTile(
                title: Text(
                  petitionID,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text('${context.l10n.signedOn}${_formatDate(signedAt)}'),
                leading: const Icon(Icons.assignment_turned_in),
              );
            },
          );
        },
      ),
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }
}
