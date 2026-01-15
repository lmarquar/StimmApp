import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stimmapp/core/extensions/context_extensions.dart';
import 'package:universal_io/io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stimmapp/core/data/services/database_service.dart';

import 'package:stimmapp/core/data/di/service_locator.dart';
import 'package:stimmapp/core/data/models/petition.dart';
import 'package:stimmapp/core/data/models/poll.dart';
import 'package:stimmapp/core/data/models/user_profile.dart';

import 'package:stimmapp/core/data/repositories/poll_repository.dart';
import 'package:stimmapp/core/data/repositories/petition_repository.dart';

class CsvExportService {
  CsvExportService._();
  static final CsvExportService instance = CsvExportService._();

  final DatabaseService databaseService = locator.databaseService;
  final PollRepository _pollRepo = PollRepository.create();
  final PetitionRepository _petitionRepo = PetitionRepository.create();

  String _csvEscape(String field) {
    final needsQuoting =
        field.contains(',') ||
        field.contains('"') ||
        field.contains('\n') ||
        field.contains('\r');
    var v = field.replaceAll('"', '""');
    return needsQuoting ? '"$v"' : v;
  }

  String _buildCsv(List<List<String>> rows) {
    final buffer = StringBuffer();
    for (final row in rows) {
      buffer.writeln(row.map(_csvEscape).join(','));
    }
    return buffer.toString();
  }

  // renamed and extended: write CSV to a temp file and open native share popup
  Future<String> _exportAndShareCsv(String baseName, String content) async {
    final date = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final fileName = '${baseName}_$date.csv';
    debugPrint('Writing CSV to temp file...');
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(content);

    try {
      // Temporarily disable Firestore network to avoid repeated reconnect attempts
      // while the native share sheet may background the app/process.
      await databaseService.disableNetwork();
    } catch (e) {
      debugPrint('Failed to disable Firestore network: $e');
    }

    try {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'text/csv')],
          text: 'CSV export: $fileName',
        ),
      );
    } catch (e) {
      debugPrint('Share failed: $e');
    } finally {
      try {
        await databaseService.enableNetwork();
      } catch (e) {
        debugPrint('Failed to re-enable Firestore network: $e');
      }
    }
    return file.path;
  }

  // Petition export: each row is a signer (result = "signed")
  Future<String> exportPetitionResults(
    BuildContext context,
    Petition petition,
    String petitionId,
  ) async {
    // Fetch signer profiles via the participants stream once
    final profiles = await _petitionRepo.getParticipantsOnce(petitionId);
    final rows = <List<String>>[];
    if (!context.mounted) {
      throw Exception('Context is no longer mounted');
    }
    rows.add([
      context.l10n.result,
      context.l10n.name,
      context.l10n.surname,
      context.l10n.email,
      context.l10n.livingAddress,
    ]);
    for (final p in profiles.whereType<UserProfile>()) {
      rows.add([
        'signed',
        p.givenName ?? '',
        p.surname ?? '',
        p.email ?? '',
        p.address ?? '',
      ]);
    }
    final csv = _buildCsv(rows);
    return _exportAndShareCsv('petition_${petition.title}', csv);
  }

  // Poll export: per-user chosen option if available; otherwise aggregate only
  Future<String> exportPollResults(
    BuildContext context,
    Poll poll,
    String pollId,
  ) async {
    final profiles = await _pollRepo.getParticipantsOnce(pollId);
    final optionMap = {for (final o in poll.options) o.id: o.label};

    final rows = <List<String>>[];
    if (!context.mounted) {
      throw Exception('Context is no longer mounted');
    }
    rows.add([
      context.l10n.result,
      context.l10n.name,
      context.l10n.surname,
      context.l10n.email,
      context.l10n.livingAddress,
    ]);

    if (profiles.isNotEmpty) {
      for (final p in profiles.whereType<UserProfile>()) {
        // try to determine selected option from user's votedPolls entry if available
        // fallback to empty result if not determinable here.
        rows.add([
          '', // option label unknown in this simplified lookup
          p.givenName ?? '',
          p.surname ?? '',
          p.email ?? '',
          p.address ?? '',
        ]);
      }
    } else {
      // Fallback: export aggregates if no per-user votes fetched
      rows.addAll(
        poll.votes.entries.map(
          (e) => ['${optionMap[e.key] ?? e.key}: ${e.value}', '', '', '', ''],
        ),
      );
    }

    final csv = _buildCsv(rows);
    return _exportAndShareCsv('poll_${poll.title}', csv);
  }
}
