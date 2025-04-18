import 'package:chatapp/features/auth/domain/entities/user_entity.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.id,
    required super.displayName,
    required super.email,
    super.phoneNumber,
    required super.photoUrl,
    super.fcmToken,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["id"].toString(),
      displayName: json["displayName"].toString(),
      email: json["email"].toString(),
      phoneNumber: json["phoneNumber"].toString(),
      photoUrl: json["photoUrl"].toString(),
      fcmToken: json["fcmToken"].toString(),
    );
  }

  factory UserModel.fromFirebaseUser(User user) {
    return UserModel(
      id: user.uid,
      displayName: user.displayName ?? "",
      email: user.email ?? "",
      phoneNumber: user.phoneNumber ?? "",
      photoUrl: user.photoURL ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "displayName": displayName,
      "email": email,
      "phoneNumber": phoneNumber,
      "photoUrl": photoUrl,
      "fcmToken": fcmToken ?? "",
    };
  }
}
