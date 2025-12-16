import 'package:cloud_firestore/cloud_firestore.dart';

class PollOption {
  final String id;
  final String label;
  const PollOption({required this.id, required this.label});

  factory PollOption.fromMap(Map<String, dynamic> m) =>
      PollOption(id: m['id'] as String, label: m['label'] as String);
  Map<String, dynamic> toMap() => {'id': id, 'label': label};
}

class Poll {
  final String id;
  final String title;
  final String description;
  final List<String> tags;
  final List<PollOption> options;
  final Map<String, int> votes; // optionId -> count
  final String createdBy;
  final DateTime createdAt;

  Poll({
    required this.id,
    required this.title,
    required this.description,
    required this.tags,
    required this.options,
    required this.votes,
    required this.createdBy,
    required this.createdAt,
  });

  int get totalVotes => votes.values.fold(0, (a, b) => a + b);

  Poll copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? tags,
    List<PollOption>? options,
    Map<String, int>? votes,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return Poll(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      options: options ?? this.options,
      votes: votes ?? this.votes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static Poll fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snap,
    SnapshotOptions? _,
  ) {
    final data = snap.data()!;
    return Poll(
      id: snap.id,
      title: (data['title'] ?? '') as String,
      description: (data['description'] ?? '') as String,
      tags: (data['tags'] as List?)?.cast<String>() ?? const [],
      options: (data['options'] as List?)
              ?.map((e) => PollOption.fromMap(Map<String, dynamic>.from(e)))
              .toList() ??
          const [],
      votes: Map<String, int>.from(data['votes'] ?? const <String, int>{}),
      createdBy: (data['createdBy'] ?? '') as String,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  static Map<String, Object?> toFirestore(Poll p, SetOptions? _) {
    return {
      'title': p.title,
      'description': p.description,
      'tags': p.tags,
      'options': p.options.map((o) => o.toMap()).toList(),
      'votes': p.votes,
      'createdBy': p.createdBy,
      'createdAt': Timestamp.fromDate(p.createdAt),
      'titleLowercase': p.title.toLowerCase(),
    };
  }
}
