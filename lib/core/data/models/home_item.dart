abstract class HomeItem {
  String get id;
  String get title;
  String get description;
  String? get state;
  DateTime get expiresAt;
  DateTime get createdAt;
  String get createdBy;
  int get participantCount;
}
