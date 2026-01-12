import 'package:flutter/material.dart';
import 'package:stimmapp/app/mobile/widgets/search_text_field.dart';
import 'package:stimmapp/core/constants/internal_constants.dart';
import 'package:stimmapp/core/data/models/home_item.dart';
import 'package:stimmapp/core/data/models/user_profile.dart';
import 'package:stimmapp/core/data/repositories/user_repository.dart';
import 'package:stimmapp/core/data/services/auth_service.dart';
import 'package:stimmapp/core/extensions/context_extensions.dart';

class BaseOverviewPage<T extends HomeItem> extends StatefulWidget {
  const BaseOverviewPage({
    super.key,
    required this.streamProvider,
    required this.itemBuilder,
  });

  final Stream<List<T>> Function(String query, String status) streamProvider;
  final Widget Function(BuildContext context, T item) itemBuilder;

  @override
  State<BaseOverviewPage<T>> createState() => _BaseOverviewPageState<T>();
}

class _BaseOverviewPageState<T extends HomeItem> extends State<BaseOverviewPage<T>>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
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

  Widget _buildItemList(String status) {
    return FutureBuilder<UserProfile?>(
      future: _userProfileFuture,
      builder: (context, userSnap) {
        if (userSnap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final userProfile = userSnap.data;
        return StreamBuilder<List<T>>(
          stream: widget.streamProvider(_query, status),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            var items = snap.data ?? const [];
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
              itemBuilder: (context, i) => widget.itemBuilder(context, items[i]),
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
                  _buildItemList(IConst.active),
                  _buildItemList(IConst.closed),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
