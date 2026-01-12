import 'package:flutter/material.dart';
import 'package:stimmapp/core/data/models/user_profile.dart';
import 'package:stimmapp/core/extensions/context_extensions.dart';

class ParticipantsListPage extends StatelessWidget {
  const ParticipantsListPage({
    super.key,
    required this.participantsStream,
  });

  final Stream<List<UserProfile>> participantsStream;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.participantsList),
      ),
      body: StreamBuilder<List<UserProfile>>(
        stream: participantsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(context.l10n.error));
          }
          final participants = snapshot.data ?? [];
          if (participants.isEmpty) {
            return Center(child: Text(context.l10n.noData));
          }
          return ListView.builder(
            itemCount: participants.length,
            itemBuilder: (context, index) {
              final user = participants[index];
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(user.displayName ?? context.l10n.anonymous),
                subtitle: Text(user.email ?? ''),
              );
            },
          );
        },
      ),
    );
  }
}
