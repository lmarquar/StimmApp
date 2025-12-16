import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stimmapp/core/data/models/petition.dart';
import 'package:stimmapp/core/data/repositories/petition_repository.dart';

class PetitionDetailPage extends StatelessWidget {
  const PetitionDetailPage({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    final repo = PetitionRepository.create();
    return Scaffold(
      appBar: AppBar(title: const Text('Petition')),
      body: StreamBuilder<Petition?>(
        stream: repo.watch(id),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final p = snap.data;
          if (p == null) return const Center(child: Text('Not found'));
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
                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please sign in')));
                        return;
                      }
                      await repo.sign(p.id, user.uid);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Signed')));
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
