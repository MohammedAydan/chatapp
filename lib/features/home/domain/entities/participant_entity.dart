import 'package:equatable/equatable.dart';

abstract class ParticipantEntity extends Equatable {
  final String id;
  final String? displayName;
  final String? phoneNumber;
  final String photoUrl;
  final String createdAt;
  final String? fcmToken;

  const ParticipantEntity({
    required this.id,
    this.displayName,
    this.phoneNumber,
    required this.photoUrl,
    required this.createdAt,
    this.fcmToken,
  });

  Map<String, dynamic> toJson();

  @override
  List<Object?> get props => [
    id,
    displayName,
    phoneNumber,
    photoUrl,
    createdAt,
    fcmToken,
  ];
}
