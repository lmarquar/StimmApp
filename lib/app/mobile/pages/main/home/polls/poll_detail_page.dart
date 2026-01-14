import 'package:flutter/material.dart';
import 'package:stimmapp/app/mobile/widgets/base_detail_page.dart';
import 'package:stimmapp/app/mobile/widgets/snackbar_utils.dart';
import 'package:stimmapp/core/data/models/poll.dart';
import 'package:stimmapp/core/data/repositories/poll_repository.dart';
import 'package:stimmapp/core/data/services/auth_service.dart';
import 'package:stimmapp/core/extensions/context_extensions.dart';

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
      bottomAction: ElevatedButton(
        onPressed: () async {
          final optionId = _selectedOptionId;
          if (optionId == null) return;
          final user = authService.currentUser;
          if (user == null) {
            if (!context.mounted) return;
            showErrorSnackBar(context.l10n.pleaseSignInFirst);
            return;
          }
          await repo.vote(
            pollId: widget.id,
            optionId: optionId,
            uid: user.uid,
          );
          if (!context.mounted) return;
          showSuccessSnackBar(context.l10n.voted);
        },
        child: const Text('Vote'),
      ),
    );
  }
}
