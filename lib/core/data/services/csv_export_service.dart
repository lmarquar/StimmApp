import 'package:universal_io/io.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:stimmapp/core/data/di/service_locator.dart';
import 'package:stimmapp/core/data/models/petition.dart';
import 'package:stimmapp/core/data/models/poll.dart';
import 'package:stimmapp/core/data/models/user_profile.dart';
import 'package:stimmapp/core/data/repositories/user_repository.dart';

class CsvExportService {
  CsvExportService._();
  static final CsvExportService instance = CsvExportService._();

  final FirebaseFirestore _db = locator.database;

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

  Future<String> _writeToTemp(String baseName, String content) async {
    final date = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final fileName = '${baseName}_$date.csv';
    print('Writing CSV to temp file...');
    final dir = Directory.systemTemp;
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(content);
    return file.path;
  }

  // Petition export: each row is a signer (result = "signed")
  Future<String> exportPetitionResults(
    Petition petition,
    String petitionId,
  ) async {
    // Fetch signer profiles via the participants stream once
    final signersSnap = await _db
        .collection('petitions')
        .doc(petitionId)
        .collection('signatures')
        .get();

    final uids = signersSnap.docs.map((d) => d.id).toList();
    final userRepo = UserRepository.create();
    final profiles = await Future.wait(uids.map((u) => userRepo.getById(u)));
    final rows = <List<String>>[];
    rows.add(['result', 'Name', 'Surname', 'Email', 'Living address']);
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
    return _writeToTemp('petition_${petition.title}', csv);
  }

  // Poll export: per-user chosen option if available; otherwise aggregate only
  Future<String> exportPollResults(Poll poll, String pollId) async {
    // Read votes subcollection: { uid, optionId }
    final votesSnap = await _db
        .collection('polls')
        .doc(pollId)
        .collection('votes')
        .get();
    final voteDocs = votesSnap.docs;

    final optionMap = {for (final o in poll.options) o.id: o.label};

    final rows = <List<String>>[];
    rows.add(['result', 'Name', 'Surname', 'Email', 'Living address']);

    if (voteDocs.isNotEmpty) {
      final uids = voteDocs.map((d) => d.id).toList();
      final userRepo = UserRepository.create();
      final profiles = await Future.wait(uids.map((u) => userRepo.getById(u)));
      final profileByUid = <String, UserProfile>{
        for (final p in profiles.whereType<UserProfile>()) p.uid: p,
      };

      for (final doc in voteDocs) {
        print(doc.data());
        final uid = doc.id;
        final optionId = (doc.data()['optionId'] ?? '') as String;
        final optionLabel = optionMap[optionId] ?? optionId;
        final p = profileByUid[uid];
        rows.add([
          optionLabel,
          p?.givenName ?? '',
          p?.surname ?? '',
          p?.email ?? '',
          p?.address ?? '',
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
    print(csv);
    return _writeToTemp('poll_${poll.title}', csv);
  }
}
