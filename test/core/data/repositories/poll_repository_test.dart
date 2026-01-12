import 'package:flutter_test/flutter_test.dart';
import 'package:stimmapp/core/data/services/database_service.dart';
import 'package:stimmapp/core/data/models/poll.dart';
import 'package:stimmapp/core/data/models/user_profile.dart';
import 'package:stimmapp/core/data/repositories/poll_repository.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:stimmapp/core/data/di/service_locator.dart';
import 'package:stimmapp/core/constants/internal_constants.dart';

void main() {
  late PollRepository pollRepository;
  late FakeFirebaseFirestore fakeFirebaseFirestore;
  late DatabaseService databaseService;

  setUp(() {
    fakeFirebaseFirestore = FakeFirebaseFirestore();
    databaseService = DatabaseService(fakeFirebaseFirestore);
    pollRepository = PollRepository(databaseService);
    locator.setDatabaseForTest(fakeFirebaseFirestore);
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
      expiresAt: DateTime.now().add(const Duration(days: 1)),
      status: IConst.active,
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
      final stream = pollRepository.list(status: IConst.active);

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

    test('closeExpiredPolls updates status of expired polls', () async {
      // Create one expired poll
      final expiredPoll = tPoll.copyWith(
        id: 'expired',
        expiresAt: DateTime.now().subtract(const Duration(days: 1)),
      );
      final expiredPollId = await pollRepository.createPoll(expiredPoll);

      // Create one active poll
      final activePoll = tPoll.copyWith(id: 'active');
      final activePollId = await pollRepository.createPoll(activePoll);

      // Close expired polls
      await pollRepository.closeExpiredPolls();

      // Check statuses
      final expiredPollAfter = await pollRepository.get(expiredPollId);
      final activePollAfter = await pollRepository.get(activePollId);

      expect(expiredPollAfter, isNotNull);
      expect(expiredPollAfter!.status, IConst.closed);
      expect(activePollAfter, isNotNull);
      expect(activePollAfter!.status, IConst.active);
    });

    test('watchParticipants returns profiles of voters', () async {
      final pollId = await pollRepository.createPoll(tPoll);

      // Add a user profile
      final user = UserProfile(
        uid: 'user1',
        email: 'user1@test.com',
        displayName: 'User One',
      );
      await fakeFirebaseFirestore
          .collection('users')
          .doc(user.uid)
          .set(user.toJson());

      // Vote
      await pollRepository.vote(pollId: pollId, optionId: 'opt1', uid: user.uid);

      final participants = await pollRepository.watchParticipants(pollId).first;

      expect(participants, hasLength(1));
      expect(participants.first.uid, user.uid);
      expect(participants.first.displayName, user.displayName);
    });

    test('delete removes a poll', () async {
      final pollId = await pollRepository.createPoll(tPoll);
      await pollRepository.delete(pollId);
      final poll = await pollRepository.get(pollId);
      expect(poll, isNull);
    });
  });
}
