import 'package:flutter_test/flutter_test.dart';
import 'package:stimmapp/core/data/firebase/firestore/database_service.dart';
import 'package:stimmapp/core/data/models/poll.dart';
import 'package:stimmapp/core/data/repositories/poll_repository.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:stimmapp/core/di/service_locator.dart';

void main() {
  late PollRepository pollRepository;
  late FakeFirebaseFirestore fakeFirebaseFirestore;
  late DatabaseService databaseService;

  setUp(() {
    fakeFirebaseFirestore = FakeFirebaseFirestore();
    databaseService = DatabaseService(fakeFirebaseFirestore);
    pollRepository = PollRepository(databaseService);
    locator.setFirestoreForTest(fakeFirebaseFirestore);
  });

  group('PollRepository', () {
    final tPoll = Poll(
      id: '1',
      title: 'Test Poll',
      description: 'A test poll',
      tags: [],
      options: [PollOption(id: 'opt1', label: 'Option 1')],
      votes: {},
      createdBy: 'user1',
      createdAt: DateTime(2023),
    );

    test('createPoll and watch work correctly', () async {
      final pollId = await pollRepository.createPoll(tPoll);
      final stream = pollRepository.watch(pollId);

      expect(
        stream,
        emits(predicate<Poll?>((p) => p != null && p.title == tPoll.title)),
      );
    });

    test('list returns a stream of polls', () async {
      await pollRepository.createPoll(tPoll);
      final stream = pollRepository.list();

      expect(
        stream,
        emits(
          predicate<List<Poll>>(
            (list) => list.isNotEmpty && list.first.title == tPoll.title,
          ),
        ),
      );
    });

    test('vote increments the vote count', () async {
      final pollId = await pollRepository.createPoll(
        tPoll.copyWith(votes: {'opt1': 0}),
      );

      await pollRepository.vote(pollId: pollId, optionId: 'opt1', uid: 'user1');

      final poll = await pollRepository.get(pollId);
      expect(poll, isNotNull);
      expect(poll!.votes['opt1'], 1);
    });

    test('a user can only vote once', () async {
      final pollId = await pollRepository.createPoll(
        tPoll.copyWith(votes: {'opt1': 0}),
      );

      await pollRepository.vote(pollId: pollId, optionId: 'opt1', uid: 'user1');
      await pollRepository.vote(pollId: pollId, optionId: 'opt1', uid: 'user1');

      final poll = await pollRepository.get(pollId);
      expect(poll, isNotNull);
      expect(poll!.votes['opt1'], 1);
    });
  });
}
