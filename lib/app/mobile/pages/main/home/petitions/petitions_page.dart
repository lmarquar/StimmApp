import 'package:flutter/material.dart';
import 'package:stimmapp/app/mobile/widgets/search_text_field.dart';
import 'package:stimmapp/core/constants/internal_constants.dart';
import 'package:stimmapp/core/data/models/petition.dart';
import 'package:stimmapp/core/data/models/user_profile.dart';
import 'package:stimmapp/core/data/repositories/petition_repository.dart';
import 'package:stimmapp/core/data/repositories/user_repository.dart';
import 'package:stimmapp/core/data/services/auth_service.dart';
import 'package:stimmapp/core/extensions/context_extensions.dart';

class PetitionsPage extends StatefulWidget {
  const PetitionsPage({super.key});

  @override
  State<PetitionsPage> createState() => _PetitionsPageState();
}

class _PetitionsPageState extends State<PetitionsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _query = '';
  Future<UserProfile?>? _userProfileFuture;
  final _repo = PetitionRepository.create();

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

  Widget _buildPetitionList(String status) {
    return FutureBuilder<UserProfile?>(
      future: _userProfileFuture,
      builder: (context, userSnap) {
        if (userSnap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final userProfile = userSnap.data;
        return StreamBuilder<List<Petition>>(
          stream: _repo.list(query: _query, status: status),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            var items = snap.data ?? const <Petition>[];
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
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final p = items[i];
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
                      const Icon(Icons.edit_note, size: 18),
                      const SizedBox(width: 4),
                      Text(p.signatureCount.toString()),
                    ],
                  ),
                  onTap: () {
                    Navigator.of(
                      context,
                    ).pushNamed('/petition', arguments: p.id);
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
      appBar: TabBar(
        controller: _tabController,
        tabs: [
          Tab(text: context.l10n.active),
          Tab(text: context.l10n.closed),
        ],
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
                  _buildPetitionList(IConst.active),
                  _buildPetitionList(IConst.closed),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
