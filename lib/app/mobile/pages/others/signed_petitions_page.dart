import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignedPetitionsPage extends StatelessWidget {
  const SignedPetitionsPage({super.key});

  Stream<QuerySnapshot<Map<String, dynamic>>> _signedPetitionsStream(
    String uid,
  ) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('signedPetitions')
        .orderBy('signedAt', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('You must be signed in to view signed petitions.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Signed Petitions')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _signedPetitionsStream(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Something went wrong while loading data.'),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text('No signed petitions yet.'));
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
                subtitle: Text('Signed on ${_formatDate(signedAt)}'),
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
