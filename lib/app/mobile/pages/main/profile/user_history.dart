import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stimmapp/app/mobile/scaffolds/app_bottom_bar_buttons.dart';
import 'package:stimmapp/core/data/services/auth_service.dart';
import 'package:stimmapp/core/data/di/service_locator.dart';
import 'package:stimmapp/core/extensions/context_extensions.dart';
import 'package:stimmapp/core/theme/app_text_styles.dart';

class UserHistoryPage extends StatefulWidget {
  const UserHistoryPage({super.key});

  @override
  State<UserHistoryPage> createState() => _UserHistoryPageState();
}

class _UserHistoryPageState extends State<UserHistoryPage> {
  late Future<List<Map<String, dynamic>>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = _fetchUserHistory();
  }

  Future<List<Map<String, dynamic>>> _fetchUserHistory() async {
    final user = authService.value.currentUser;
    if (user == null) {
      // Handle case where user is not logged in
      return [];
    }
    final db = locator.database;
    final userDocRef = db.collection('users').doc(user.uid);

    // Fetch documents from subcollections to get the IDs.
    final signedPetitionsFuture = userDocRef
        .collection('signedPetitions')
        .get();
    final votedPollsFuture = userDocRef.collection('votedPolls').get();

    final results = await Future.wait([
      signedPetitionsFuture,
      votedPollsFuture,
    ]);

    final signedPetitionsSnapshot = results[0] as QuerySnapshot;
    final votedPollsSnapshot = results[1] as QuerySnapshot;

    final petitionIds = signedPetitionsSnapshot.docs
        .map((doc) => doc.id)
        .toList();
    final pollIds = votedPollsSnapshot.docs.map((doc) => doc.id).toList();
    final List<Future<DocumentSnapshot>> petitionFutures = petitionIds
        .map((id) => db.collection('petitions').doc(id).get())
        .toList();

    final List<Future<DocumentSnapshot>> pollFutures = pollIds
        .map((id) => db.collection('polls').doc(id).get())
        .toList();

    final petitionSnapshots = await Future.wait(petitionFutures);
    final pollSnapshots = await Future.wait(pollFutures);

    final List<Map<String, dynamic>> historyItems = [];

    for (var doc in petitionSnapshots) {
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        historyItems.add({
          'title': data['title'] ?? 'No Title',
          'type': 'Petition',
          'timestamp': data['createdAt'], // Let's assume this exists for now
        });
      }
    }

    for (var doc in pollSnapshots) {
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        historyItems.add({
          'title': data['title'] ?? 'No Title',
          'type': 'Poll',
          'timestamp': data['createdAt'], // Assuming a timestamp field exists
        });
      }
    }
    // Sort items by timestamp (newest first), handling nulls gracefully.
    historyItems.sort((a, b) {
      final aTimestamp = a['timestamp'] as Timestamp?;
      final bTimestamp = b['timestamp'] as Timestamp?;

      // Handle null timestamps gracefully by sorting them to the end.
      if (aTimestamp == null && bTimestamp == null) return 0;
      if (aTimestamp == null) return 1; // a is null, push to end
      if (bTimestamp == null) return -1; // b is null, push to end

      return bTimestamp.compareTo(aTimestamp);
    });
    return historyItems;
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomBarButtons(
      appBar: AppBar(
        title: Text(context.l10n.activityHistory, style: AppTextStyles.lBold),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(context.l10n.noActivityFound, style: AppTextStyles.m),
            );
          }

          final historyItems = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: historyItems.length,
            itemBuilder: (context, index) {
              final item = historyItems[index];
              final isPetition = item['type'] == 'Petition';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  leading: Icon(
                    isPetition ? Icons.article : Icons.poll,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(item['title'], style: AppTextStyles.mBold),
                  subtitle: Text(item['type'], style: AppTextStyles.s),
                ),
              );
            },
          );
        },
      ),
      buttons: const [], // No buttons needed for this page
    );
  }
}
