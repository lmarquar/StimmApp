import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:stimmapp/core/data/models/poll.dart';

void main() {
  group('PollOption', () {
    final pollOption = PollOption(id: '1', label: 'Option 1');
    final pollOptionMap = {'id': '1', 'label': 'Option 1'};

    test('fromMap creates a PollOption object from a map', () {
      final result = PollOption.fromMap(pollOptionMap);
      expect(result.id, pollOption.id);
      expect(result.label, pollOption.label);
    });

    test('toMap returns a map from a PollOption object', () {
      final result = pollOption.toMap();
      expect(result, pollOptionMap);
    });
  });

  group('Poll', () {
    final timestamp = Timestamp.fromDate(DateTime(2023));
    final poll = Poll(
      id: 'poll1',
      title: 'Test Poll',
      description: 'This is a test poll.',
      tags: ['test', 'poll'],
      options: [PollOption(id: 'opt1', label: 'Option 1')],
      votes: {'opt1': 10},
      createdBy: 'user1',
      createdAt: timestamp.toDate(),
      expiresAt: timestamp.toDate(),
    );

    final pollFirestoreData = {
      'title': 'Test Poll',
      'description': 'This is a test poll.',
      'tags': ['test', 'poll'],
      'options': [
        {'id': 'opt1', 'label': 'Option 1'},
      ],
      'votes': {'opt1': 10},
      'createdBy': 'user1',
      'createdAt': timestamp,
      'titleLowercase': 'test poll',
    };

    test(
      'fromFirestore creates a Poll object from a firestore snapshot',
      () async {
        final firestore = FakeFirebaseFirestore();
        final snap = await firestore.collection('polls').add(pollFirestoreData);

        final result = Poll.fromFirestore(await snap.get(), null);

        expect(result.id, isNotEmpty);
        expect(result.title, poll.title);
        expect(result.description, poll.description);
        expect(result.tags, poll.tags);
        expect(result.options.first.id, poll.options.first.id);
        expect(result.votes, poll.votes);
        expect(result.createdBy, poll.createdBy);
        // Timestamps are not identical, but should be close
        expect(result.createdAt.year, poll.createdAt.year);
      },
    );

    test('toFirestore returns a map from a Poll object', () {
      final result = Poll.toFirestore(poll, null);
      expect(result, pollFirestoreData);
    });
  });
}
