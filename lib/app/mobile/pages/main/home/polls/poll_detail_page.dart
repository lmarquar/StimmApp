import 'package:flutter/material.dart';
import 'package:stimmapp/app/mobile/pages/main/home/base_detail_page.dart';
import 'package:stimmapp/core/data/models/poll.dart';
import 'package:stimmapp/core/data/repositories/poll_repository.dart';
import 'package:stimmapp/core/data/services/auth_service.dart';
import 'package:stimmapp/core/extensions/context_extensions.dart';
import 'package:stimmapp/app/mobile/widgets/sign_action_button.dart';

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
    return BaseDetailPage<Poll>(
      id: widget.id,
      appBarTitle: context.l10n.pollDetails,
      streamProvider: repo.watch,
      participantsStream: repo.watchParticipants(widget.id),
      contentBuilder: (context, poll) {
        final total = poll.totalVotes;
        return RadioGroup<String>(
          groupValue: _selectedOptionId,
          onChanged: (v) => setState(() => _selectedOptionId = v),
          child: ListView(
            children: [
              ...poll.options.map((o) {
                final count = poll.votes[o.id] ?? 0;
                final pct = total == 0 ? 0 : (count / total * 100).round();
                return ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(o.label)),
                      Text('$count • $pct%'),
                    ],
                  ),
                  leading: Radio<String>(value: o.id),
                  onTap: () => setState(() => _selectedOptionId = o.id),
                );
              }),
            ],
          ),
        );
      },
      bottomAction: SignActionButton(
        label: context.l10n.vote,
        participantsStream: repo.watchParticipants(widget.id),
        onAction: () async {
          final optionId = _selectedOptionId;
          if (optionId == null) return;
          final user = authService.currentUser!;
          await repo.vote(pollId: widget.id, optionId: optionId, uid: user.uid);
          if (context.mounted) Navigator.pop(context);
        },
        successMessage: context.l10n.voted,
      ),
    );
  }
}
