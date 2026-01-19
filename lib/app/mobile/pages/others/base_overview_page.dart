import 'package:flutter/material.dart';
import 'package:stimmapp/app/mobile/widgets/banner_ad_widget.dart';
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

class _BaseOverviewPageState<T extends HomeItem>
    extends State<BaseOverviewPage<T>>
    with SingleTickerProviderStateMixin {
  static const int _itemsPerAd = 7; // Show an ad after every 7 items.

  late TabController _tabController;
  String _query = '';
  Future<UserProfile?>? _userProfileFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final uid = authService.currentUser?.uid;
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

            final standardAdCount = (items.length / _itemsPerAd).floor();
            // Ensure at least one ad is shown if the list is short but not empty.
            final showFallbackAd = items.isNotEmpty && standardAdCount == 0;
            final totalCount =
                items.length + standardAdCount + (showFallbackAd ? 1 : 0);

            return ListView.builder(
              itemCount: totalCount,
              itemBuilder: (context, index) {
                final isAdTile =
                    (index + 1) % (_itemsPerAd + 1) == 0 ||
                    (showFallbackAd && index == totalCount - 1);

                if (isAdTile) {
                  return const BannerAdWidget();
                } else {
                  final adSlot = (index + 1) ~/ (_itemsPerAd + 1);
                  final itemIndex = index - adSlot;
                  return Column(
                    children: [
                      widget.itemBuilder(context, items[itemIndex]),
                      const Divider(height: 1),
                    ],
                  );
                }
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
