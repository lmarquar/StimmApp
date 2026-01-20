import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stimmapp/app/mobile/pages/main/home/participants_list_page.dart';
import 'package:stimmapp/core/data/models/home_item.dart';
import 'package:stimmapp/core/data/models/user_profile.dart';
import 'package:stimmapp/core/extensions/context_extensions.dart';

class BaseDetailPage<T extends HomeItem> extends StatelessWidget {
  const BaseDetailPage({
    super.key,
    required this.id,
    required this.appBarTitle,
    required this.streamProvider,
    required this.contentBuilder,
    this.bottomAction,
    this.participantsStream,
  });

  final String id;
  final String appBarTitle;
  final Stream<T?> Function(String id) streamProvider;
  final Widget Function(BuildContext context, T item) contentBuilder;
  final Widget? bottomAction;
  final Stream<List<UserProfile>>? participantsStream;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(appBarTitle)),
      body: StreamBuilder<T?>(
        stream: streamProvider(id),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final item = snap.data;
          if (item == null) return Center(child: Text(context.l10n.notFound));

          final now = DateTime.now();
          final isExpired = item.expiresAt.isBefore(now);
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.state != null && item.state!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Chip(label: Text(context.l10n.relatedToState(item.state!))),
                ],
                const SizedBox(height: 16),
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(item.description),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${context.l10n.participants}: ${item.participantCount}',
                    ),
                    if (participantsStream != null)
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (context) => ParticipantsListPage(
                                    participantsStream: participantsStream!,
                                  ),
                            ),
                          );
                        },
                        child: Text(context.l10n.viewParticipants),
                      ),
                  ],
                ),
                Text(
                  '${context.l10n.expiresOn}: ${DateFormat('dd.MM.yyyy').format(item.expiresAt)}',
                ),
                if (isExpired) ...[
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.closed,
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(color: Theme.of(context).colorScheme.error),
                  ),
                ],
                const SizedBox(height: 16),
                Expanded(child: contentBuilder(context, item)),
                if (!isExpired && bottomAction != null) ...[
                  const SizedBox(height: 16),
                  SizedBox(width: double.infinity, child: bottomAction!),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
