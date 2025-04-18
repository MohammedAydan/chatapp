class UserEntity {
  final String id;
  final String displayName;
  final String email;
  final String? phoneNumber;
  final String photoUrl;
  final String? fcmToken;

  UserEntity({
    required this.id,
    required this.displayName,
    required this.email,
    this.phoneNumber,
    required this.photoUrl,
    this.fcmToken,
  });
}
