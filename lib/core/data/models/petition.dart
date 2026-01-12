import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stimmapp/core/constants/internal_constants.dart';
import 'package:stimmapp/core/data/models/home_item.dart';

class Petition implements HomeItem {
  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  final List<String> tags;
  final int signatureCount;
  @override
  final String createdBy;
  @override
  final DateTime createdAt;
  @override
  final DateTime expiresAt;
  final String status;
  @override
  final String? state;

  Petition({
    required this.id,
    required this.title,
    required this.description,
    required this.tags,
    required this.signatureCount,
    required this.createdBy,
    required this.createdAt,
    required this.expiresAt,
    this.status = IConst.active,
    this.state,
  });

  @override
  int get participantCount => signatureCount;

  Petition copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? tags,
    int? signatureCount,
    String? createdBy,
    DateTime? createdAt,
    DateTime? expiresAt,
    String? status,
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
      expiresAt: expiresAt ?? this.expiresAt,
      status: status ?? this.status,
      state: state ?? this.state,
    );
  }

  static Petition fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snap,
    SnapshotOptions? _,
  ) {
    final data = snap.data()!;
    final createdAt =
        (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
    return Petition(
      id: snap.id,
      title: (data['title'] ?? '') as String,
      description: (data['description'] ?? '') as String,
      tags: (data['tags'] as List?)?.cast<String>() ?? const [],
      signatureCount: (data['signatureCount'] ?? 0) as int,
      createdBy: (data['createdBy'] ?? '') as String,
      createdAt: createdAt,
      expiresAt:
          (data['expiresAt'] as Timestamp?)?.toDate() ??
          createdAt.add(const Duration(days: 28)),
      status: (data['status'] ?? IConst.active) as String,
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
      'expiresAt': Timestamp.fromDate(p.expiresAt),
      'status': p.status,
      'titleLowercase': p.title.toLowerCase(),
      'state': p.state,
    };
  }
}
