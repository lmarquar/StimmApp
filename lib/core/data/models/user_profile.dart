import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String? displayName;
  final String? email;
  final String? state;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? isPro;
  final DateTime? wentProAt;
  final bool? subscribedToPro;

  /// Returns the date when the subscription expires (30 days after purchase).
  DateTime? get subscriptionEndsAt {
    if (wentProAt == null) return null;
    return wentProAt!.add(const Duration(days: 30));
  }

  // ID Card Fields
  final String? surname;
  final String? givenName;
  final DateTime? dateOfBirth;
  final String? nationality;
  final String? placeOfBirth;
  final DateTime? expiryDate;
  final String? idNumber;
  final String? address;
  final String? height;

  bool get isAdmin => email == 'service@stimmapp.org';

  const UserProfile({
    required this.uid,
    this.displayName,
    this.email,
    this.state,
    this.createdAt,
    this.updatedAt,
    this.surname,
    this.givenName,
    this.dateOfBirth,
    this.nationality,
    this.placeOfBirth,
    this.expiryDate,
    this.idNumber,
    this.address,
    this.height,
    this.isPro,
    this.wentProAt,
    this.subscribedToPro,
  });

  UserProfile copyWith({
    String? uid,
    String? displayName,
    String? email,
    String? state,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? surname,
    String? givenName,
    DateTime? dateOfBirth,
    String? nationality,
    String? placeOfBirth,
    DateTime? expiryDate,
    String? idNumber,
    String? address,
    String? height,
    bool? isPro,
    DateTime? wentProAt,
    bool? subscribedToPro,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      state: state ?? this.state,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      surname: surname ?? this.surname,
      givenName: givenName ?? this.givenName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      nationality: nationality ?? this.nationality,
      placeOfBirth: placeOfBirth ?? this.placeOfBirth,
      expiryDate: expiryDate ?? this.expiryDate,
      idNumber: idNumber ?? this.idNumber,
      address: address ?? this.address,
      height: height ?? this.height,
      isPro: isPro ?? this.isPro,
      wentProAt: wentProAt ?? this.wentProAt,
      subscribedToPro: subscribedToPro ?? this.subscribedToPro,
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json, String uid) {
    return UserProfile(
      uid: uid,
      displayName: json['displayName'] as String?,
      email: json['email'] as String?,
      state: json['state'] as String?,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate(),
      surname: json['surname'] as String?,
      givenName: json['givenName'] as String?,
      dateOfBirth: (json['dateOfBirth'] as Timestamp?)?.toDate(),
      nationality: json['nationality'] as String?,
      placeOfBirth: json['placeOfBirth'] as String?,
      expiryDate: (json['expiryDate'] as Timestamp?)?.toDate(),
      idNumber: json['idNumber'] as String?,
      address: json['address'] as String?,
      height: json['height'] as String?,
      isPro: json['isPro'] as bool?,
      wentProAt: (json['wentProAt'] as Timestamp?)?.toDate(),
      subscribedToPro: json['subscribedToPro'] as bool?,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'displayName': displayName,
      'email': email,
      'state': state,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'surname': surname,
      'givenName': givenName,
      'dateOfBirth': dateOfBirth != null
          ? Timestamp.fromDate(dateOfBirth!)
          : null,
      'nationality': nationality,
      'placeOfBirth': placeOfBirth,
      'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
      'idNumber': idNumber,
      'address': address,
      'height': height,
      'isPro': isPro,
      'wentProAt': wentProAt != null ? Timestamp.fromDate(wentProAt!) : null,
      'subscribedToPro': subscribedToPro,
    };
  }
}
