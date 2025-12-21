import 'package:flutter/material.dart';
import 'package:stimmapp/app/mobile/widgets/search_text_field.dart';
import 'package:stimmapp/core/data/models/poll.dart';
import 'package:stimmapp/core/data/repositories/poll_repository.dart';
import 'package:stimmapp/core/extensions/context_extensions.dart';

class PollsPage extends StatefulWidget {
  const PollsPage({super.key});

  @override
  State<PollsPage> createState() => _PollsPageState();
}

class _PollsPageState extends State<PollsPage> {
  final _repo = PollRepository.create();
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            SearchTextField(
              hint: context.l10n.searchTextField,
              onChanged: (q) => setState(() => _query = q),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<List<Poll>>(
                stream: _repo.list(query: _query),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final items = snap.data ?? const <Poll>[];
                  if (items.isEmpty) {
                    return Center(child: Text(context.l10n.noData));
                  }
                  return ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final p = items[i];
                      final total = p.totalVotes;
                      return ListTile(
                        title: Text(p.title),
                        subtitle: Text(
                          p.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.how_to_vote, size: 18),
                            const SizedBox(width: 4),
                            Text(total.toString()),
                          ],
                        ),
                        onTap: () {
                          Navigator.of(
                            context,
                          ).pushNamed('/poll', arguments: p.id);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
