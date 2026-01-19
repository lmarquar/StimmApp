import 'package:flutter/material.dart';
import 'package:stimmapp/app/mobile/pages/others/base_overview_page.dart';
import 'package:stimmapp/core/data/models/poll.dart';
import 'package:stimmapp/core/data/repositories/poll_repository.dart';

class PollsPage extends StatelessWidget {
  const PollsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = PollRepository.create();
    return BaseOverviewPage<Poll>(
      streamProvider: (query, status) =>
          repo.list(query: query, status: status),
      itemBuilder: (context, p) {
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
            Navigator.of(context).pushNamed('/poll', arguments: p.id);
          },
        );
      },
    );
  }
}
