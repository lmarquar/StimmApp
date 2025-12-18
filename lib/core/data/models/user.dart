import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  final List<String> signedPetitions;
  final List<String> votedPolls;

  User({
    required this.uid,
    required this.signedPetitions,
    required this.votedPolls,
  });

  User copyWith({
    String? uid,
    List<String>? signedPetitions,
    List<String>? votedPolls,
  }) {
    return User(
      uid: uid ?? this.uid,
      signedPetitions: signedPetitions ?? this.signedPetitions,
      votedPolls: votedPolls ?? this.votedPolls,
    );
  }

  static User fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snap,
    SnapshotOptions? _,
  ) {
    final data = snap.data()!;
    return User(
      uid: snap.id,
      signedPetitions: List<String>.from(
        data['signedPetitions'] ?? const <String>[],
      ),
      votedPolls: List<String>.from(data['votedPolls'] ?? const <String>[]),
    );
  }

  static Map<String, Object?> toFirestore(User u, SetOptions? _) {
    return {'signedPetitions': u.signedPetitions, 'votedPolls': u.votedPolls};
  }
}
