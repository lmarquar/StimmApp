import 'package:flutter/material.dart';
import 'package:stimmapp/app/mobile/widgets/search_text_field.dart';
import 'package:stimmapp/core/constants/internal_constants.dart';
import 'package:stimmapp/core/data/models/poll.dart';
import 'package:stimmapp/core/data/models/user_profile.dart';
import 'package:stimmapp/core/data/repositories/poll_repository.dart';
import 'package:stimmapp/core/data/repositories/user_repository.dart';
import 'package:stimmapp/core/data/services/auth_service.dart';
import 'package:stimmapp/core/extensions/context_extensions.dart';

class PollsPage extends StatefulWidget {
  const PollsPage({super.key});

  @override
  State<PollsPage> createState() => _PollsPageState();
}

class _PollsPageState extends State<PollsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _repo = PollRepository.create();
  String _query = '';
  Future<UserProfile?>? _userProfileFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final uid = authService.value.currentUser?.uid;
    if (uid != null) {
      _userProfileFuture = UserRepository.create().getById(uid);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildPollList(String status) {
    return FutureBuilder<UserProfile?>(
      future: _userProfileFuture,
      builder: (context, userSnap) {
        if (userSnap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final userProfile = userSnap.data;
        return StreamBuilder<List<Poll>>(
          stream: _repo.list(query: _query, status: status),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            var items = snap.data ?? const <Poll>[];
            if (userProfile != null) {
              items = items.where((p) {
                return p.state == null || p.state == userProfile.state;
              }).toList();
            }
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
                    Navigator.of(context).pushNamed('/poll', arguments: p.id);
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.polls),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: IConst.active),
            Tab(text: IConst.closed),
          ],
        ),
      ),
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
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPollList(IConst.active),
                  _buildPollList(IConst.closed),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
