import 'package:cloud_firestore/cloud_firestore.dart';

class Petition {
  final String id;
  final String title;
  final String description;
  final List<String> tags;
  final int signatureCount;
  final String createdBy;
  final DateTime createdAt;
  final bool isRegional;
  final String? state;

  Petition({
    required this.id,
    required this.title,
    required this.description,
    required this.tags,
    required this.signatureCount,
    required this.createdBy,
    required this.createdAt,
    this.isRegional = false,
    this.state,
  });

  Petition copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? tags,
    int? signatureCount,
    String? createdBy,
    DateTime? createdAt,
    bool? isRegional,
    String? state,
  }) {
    return Petition(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      signatureCount: signatureCount ?? this.signatureCount,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      isRegional: isRegional ?? this.isRegional,
      state: state ?? this.state,
    );
  }

  static Petition fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snap,
    SnapshotOptions? _,
  ) {
    final data = snap.data()!;
    return Petition(
      id: snap.id,
      title: (data['title'] ?? '') as String,
      description: (data['description'] ?? '') as String,
      tags: (data['tags'] as List?)?.cast<String>() ?? const [],
      signatureCount: (data['signatureCount'] ?? 0) as int,
      createdBy: (data['createdBy'] ?? '') as String,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRegional: (data['isRegional'] ?? false) as bool,
      state: data['state'] as String?,
    );
  }

  static Map<String, Object?> toFirestore(Petition p, SetOptions? _) {
    return {
      'title': p.title,
      'description': p.description,
      'tags': p.tags,
      'signatureCount': p.signatureCount,
      'createdBy': p.createdBy,
      'createdAt': Timestamp.fromDate(p.createdAt),
      'titleLowercase': p.title.toLowerCase(),
      'isRegional': p.isRegional,
      'state': p.state,
    };
  }
}
