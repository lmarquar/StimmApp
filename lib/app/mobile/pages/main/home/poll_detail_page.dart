import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stimmapp/core/data/models/poll.dart';
import 'package:stimmapp/core/data/repositories/poll_repository.dart';

class PollDetailPage extends StatefulWidget {
  const PollDetailPage({super.key, required this.id});
  final String id;

  @override
  State<PollDetailPage> createState() => _PollDetailPageState();
}

class _PollDetailPageState extends State<PollDetailPage> {
  String? _selectedOptionId;

  @override
  Widget build(BuildContext context) {
    final repo = PollRepository.create();
    return Scaffold(
      appBar: AppBar(title: const Text('Poll')),
      body: StreamBuilder<Poll?>(
        stream: repo.watch(widget.id),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final poll = snap.data;
          if (poll == null) return const Center(child: Text('Not found'));
          final total = poll.totalVotes;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(poll.title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(poll.description),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    children: [
                      ...poll.options.map((o) {
                        final count = poll.votes[o.id] ?? 0;
                        final pct = total == 0 ? 0 : (count / total * 100).round();
                        return RadioListTile<String>(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Text(o.label)),
                              Text('$count • $pct%'),
                            ],
                          ),
                          value: o.id,
                          groupValue: _selectedOptionId,
                          onChanged: (v) => setState(() => _selectedOptionId = v),
                        );
                      }),
                    ],
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final optionId = _selectedOptionId;
                      if (optionId == null) return;
                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please sign in')));
                        return;
                      }
                      await repo.vote(pollId: poll.id, optionId: optionId, uid: user.uid);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vote submitted')));
                    },
                    child: const Text('Vote'),
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
