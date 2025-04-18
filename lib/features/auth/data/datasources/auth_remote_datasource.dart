import 'package:chatapp/core/errors/errors.dart';
import 'package:chatapp/core/errors/failure.dart';
import 'package:chatapp/core/params/sign_in_params.dart';
import 'package:chatapp/core/params/sign_up_params.dart';
import 'package:chatapp/core/services/crashlytics_service.dart';
import 'package:chatapp/core/strings/firebase_collections.dart';
import 'package:chatapp/features/auth/data/models/user_model.dart';
import 'package:chatapp/features/auth/domain/entities/user_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class AuthRemoteDatasource {
  Future<UserEntity> signInWithGoogle();
  Future<UserEntity> getCurrentUser();
  Future<void> signOut();
  Future<UserEntity> signInWithEmailAndPassword(SignInParams params);
  Future<UserEntity> signUpWithEmailAndPassword(SignUpParams params);
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final FirebaseMessaging _messaging;

  AuthRemoteDatasourceImpl(
    this._firebaseAuth,
    this._firestore,
    this._messaging,
  );

  @override
  Future<UserEntity> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user == null || user.email == null) throw UnauthorizedFailure();
    return UserModel.fromFirebaseUser(user);
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) throw UnauthorizedFailure();

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      final user = userCredential.user;
      if (user == null || user.email == null) throw UnauthorizedFailure();
      CrashlyticsService.setUserIdentifier(user.uid);
      return await _saveUserIfNew(UserModel.fromFirebaseUser(user));
    } catch (e, stack) {
      CrashlyticsService.recordError(e, stack);
      throw FirebaseFailure("Google sign-in error: ${e.toString()}");
    }
  }

  @override
  Future<UserEntity> signInWithEmailAndPassword(SignInParams params) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: params.email,
        password: params.password,
      );

      final user = userCredential.user;
      if (user == null || user.email == null) throw UnauthorizedFailure();
      CrashlyticsService.setUserIdentifier(user.uid);
      return UserModel.fromFirebaseUser(user);
    } on FirebaseAuthException catch (e, stack) {
      CrashlyticsService.recordError(e, stack);
      if (e.code == 'user-not-found') throw NotFoundFailure();
      if (e.code == 'wrong-password') throw UnauthorizedFailure();
      throw FirebaseFailure(e.message ?? "Sign-in error");
    }
  }

  @override
  Future<UserEntity> signUpWithEmailAndPassword(SignUpParams params) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: params.email,
        password: params.password,
      );

      final user = userCredential.user;
      if (user == null || user.email == null) throw UnauthorizedFailure();
      CrashlyticsService.setUserIdentifier(user.uid);
      return await _saveUserIfNew(UserModel.fromFirebaseUser(user));
    } on FirebaseAuthException catch (e, stack) {
      CrashlyticsService.recordError(e, stack);
      throw FirebaseFailure(e.message ?? "Sign-up error");
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e, stack) {
      CrashlyticsService.recordError(e, stack);
      throw FirebaseFailure("Sign-out error: ${e.toString()}");
    }
  }

  Future<UserEntity> _saveUserIfNew(UserModel user) async {
    final token = await _messaging.getToken() ?? "";
    final docRef = _firestore
        .collection(FirebaseCollections.users)
        .doc(user.id);

    final userDoc = await docRef.get();
    if (!userDoc.exists) {
      await docRef.set({...user.toJson(), "fcmToken": token});
    }

    return user;
  }
}
