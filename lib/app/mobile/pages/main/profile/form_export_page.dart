import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stimmapp/app/mobile/widgets/snackbar_utils.dart';
import 'package:stimmapp/core/constants/internal_constants.dart';
import 'package:stimmapp/core/data/models/petition.dart';
import 'package:stimmapp/core/data/models/poll.dart';
import 'package:stimmapp/core/data/repositories/petition_repository.dart';
import 'package:stimmapp/core/data/repositories/poll_repository.dart';
import 'package:stimmapp/core/data/services/auth_service.dart';
import 'package:stimmapp/core/data/services/csv_export_service.dart';
import 'package:stimmapp/core/extensions/context_extensions.dart';

class FormExportPage extends StatefulWidget {
  const FormExportPage({super.key});

  @override
  State<FormExportPage> createState() => _FormExportPageState();
}

class _FormExportPageState extends State<FormExportPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Stream<List<Petition>> _expiredPetitionsByMe() {
    return PetitionRepository.create()
        .list(query: null, status: IConst.closed)
        .map((items) {
          final uid = authService.currentUser?.uid;
          final now = DateTime.now();
          return items
              .where((p) => p.createdBy == uid && p.expiresAt.isBefore(now))
              .toList();
        });
  }

  Stream<List<Poll>> _expiredPollsByMe() {
    return PollRepository.create().list(query: null, status: IConst.closed).map(
      (items) {
        final uid = authService.currentUser?.uid;
        final now = DateTime.now();
        return items
            .where((p) => p.createdBy == uid && p.expiresAt.isBefore(now))
            .toList();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.expiredCreations),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: context.l10n.expiredPetitions),
            Tab(text: context.l10n.expiredPolls),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildPetitionsTab(context), _buildPollsTab(context)],
      ),
    );
  }

  Widget _buildPetitionsTab(BuildContext context) {
    return StreamBuilder<List<Petition>>(
      stream: _expiredPetitionsByMe().map(
        (list) => list..sort((a, b) => b.expiresAt.compareTo(a.expiresAt)),
      ),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snap.data ?? const [];
        if (items.isEmpty) {
          return Center(child: Text(context.l10n.noExpiredItems));
        }
        return ListView.separated(
          itemCount: items.length,
          separatorBuilder: (context, i) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final p = items[i];
            return ListTile(
              title: Text(p.title),
              subtitle: Text(DateFormat('yyyy-MM-dd').format(p.expiresAt)),
              trailing: TextButton(
                onPressed: () async {
                  try {
                    final path = await CsvExportService.instance
                        .exportPetitionResults(p, p.id);
                    if (!context.mounted) return;
                    showSuccessSnackBar('${context.l10n.exportSuccess}: $path');
                  } catch (e) {
                    showErrorSnackBar('${context.l10n.exportFailed}: $e');
                  }
                },
                child: Text(context.l10n.exportCsv),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPollsTab(BuildContext context) {
    return StreamBuilder<List<Poll>>(
      stream: _expiredPollsByMe().map(
        (list) => list..sort((a, b) => b.expiresAt.compareTo(a.expiresAt)),
      ),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snap.data ?? const [];
        if (items.isEmpty) {
          return Center(child: Text(context.l10n.noExpiredItems));
        }
        return ListView.separated(
          itemCount: items.length,
          separatorBuilder: (context, i) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final p = items[i];
            return ListTile(
              title: Text(p.title),
              subtitle: Text(DateFormat('yyyy-MM-dd').format(p.expiresAt)),
              trailing: TextButton(
                onPressed: () async {
                  try {
                    final path = await CsvExportService.instance
                        .exportPollResults(p, p.id);
                    if (!context.mounted) return;
                    showSuccessSnackBar('${context.l10n.exportSuccess}: $path');
                  } catch (e) {
                    showErrorSnackBar('${context.l10n.exportFailed}: $e');
                  }
                },
                child: Text(context.l10n.exportCsv),
              ),
            );
          },
        );
      },
    );
  }
}
