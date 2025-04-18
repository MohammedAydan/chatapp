import 'package:chatapp/core/errors/errors.dart';
import 'package:chatapp/core/params/update_display_name_params.dart';
import 'package:chatapp/core/params/update_fcm_token_params.dart';
import 'package:chatapp/core/services/custom_notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:chatapp/core/errors/error_model.dart';
import 'package:chatapp/core/errors/exceptions.dart';
import 'package:chatapp/core/params/create_chat_params.dart';
import 'package:chatapp/core/params/get_chats_params.dart';
import 'package:chatapp/core/strings/firebase_collections.dart';
import 'package:chatapp/core/utils/create_chat_id.dart';
import 'package:chatapp/features/auth/data/models/user_model.dart';
import 'package:chatapp/features/auth/domain/entities/user_entity.dart';
import 'package:chatapp/features/home/data/models/chat_model.dart';
import 'package:chatapp/features/home/data/models/participant_model.dart';
import 'package:chatapp/features/home/domain/entities/chat_entity.dart';
import 'package:chatapp/core/services/crashlytics_service.dart';

abstract class ChatsRemoteDataSource {
  Future<ChatEntity> createChat(CreateChatParams params);
  Stream<List<ChatEntity>> getChats(GetChatsParams params);
  Future<void> removeChat(String chatId);
  Future<void> updateFcmToken(UpdateFcmTokenParams params);
  Future<void> updateDisplayName(UpdateDisplayNameParams params);
}

class ChatsRemoteDataSourceImpl implements ChatsRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseMessaging _messaging;

  ChatsRemoteDataSourceImpl(this._firestore, this._messaging);

  @override
  Future<ChatEntity> createChat(CreateChatParams params) async {
    try {
      final chatId = createChatId(params.participantIds);
      final docRef = _firestore
          .collection(FirebaseCollections.chats)
          .doc(chatId);

      final receiverId =
          params.participantIds.first == params.senderId
              ? params.participantIds.last
              : params.participantIds.first;

      final UserEntity receiverUser = await _getUserByEmail(receiverId);

      final senderToken = await _messaging.getToken();

      final sender = ParticipantModel(
        id: params.participant.first.id,
        displayName: params.participant.first.displayName,
        photoUrl: params.participant.first.photoUrl,
        phoneNumber: params.participant.first.phoneNumber,
        createdAt: DateTime.now().toIso8601String(),
        fcmToken: senderToken ?? '',
      );

      final receiver = ParticipantModel(
        id: receiverUser.email,
        displayName: receiverUser.email,
        photoUrl: receiverUser.photoUrl,
        phoneNumber: receiverUser.phoneNumber,
        createdAt: DateTime.now().toIso8601String(),
        fcmToken: receiverUser.fcmToken ?? '',
      );

      final chat = ChatModel(
        id: chatId,
        participant: [sender, receiver],
        participantIds: params.participantIds,
        lastMessage: params.lastMessage,
        createdAt: DateTime.now().toIso8601String(),
        chatType: params.chatType,
      );

      await docRef.set(chat.toJson());

      return chat;
    } catch (e, stack) {
      CrashlyticsService.recordError(e, stack);
      throw ServerException(
        ErrorModel(
          status: 500,
          errorMessage: 'Failed to create chat: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Stream<List<ChatEntity>> getChats(GetChatsParams params) {
    try {
      return _firestore
          .collection(FirebaseCollections.chats)
          .where("participantIds", arrayContains: params.userId)
          .where("isDeleted", isEqualTo: false)
          .orderBy("lastMessage.createdAt", descending: true)
          .limit(20)
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs
                    .map((doc) => ChatModel.fromJson(doc.data()))
                    .toList(),
          );
    } catch (e, stack) {
      CrashlyticsService.recordError(e, stack);
      throw ServerException(
        ErrorModel(
          status: 500,
          errorMessage: 'Failed to fetch chats: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<void> removeChat(String chatId) async {
    try {
      await _firestore.collection(FirebaseCollections.chats).doc(chatId).update(
        {"isDeleted": true},
      );
    } catch (e, stack) {
      CrashlyticsService.recordError(e, stack);
      throw ServerException(
        ErrorModel(
          status: 500,
          errorMessage: 'Failed to remove chat: ${e.toString()}',
        ),
      );
    }
  }

  Future<UserEntity> _getUserByEmail(String email) async {
    try {
      final query =
          await _firestore
              .collection(FirebaseCollections.users)
              .where("email", isEqualTo: email)
              .limit(1)
              .get();

      if (query.docs.isEmpty) {
        throw ServerException(
          ErrorModel(status: 404, errorMessage: "User not found"),
        );
      }

      return UserModel.fromJson(query.docs.first.data());
    } catch (e, stack) {
      CrashlyticsService.recordError(e, stack);
      throw ServerException(
        ErrorModel(
          status: 500,
          errorMessage: 'Failed to fetch user: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<void> updateFcmToken(UpdateFcmTokenParams params) async {
    try {
      final String? newFcmToken = await CustomNotificationService.getFCMToken();
      if (newFcmToken == null) return;
      bool isTokenNotUpdated = false;
      final updatedParticipants =
          params.participant.map((p) {
            if (p.id == params.userId) {
              if (newFcmToken == p.fcmToken) {
                isTokenNotUpdated = true;
              }
              return {...p.toJson(), 'fcmToken': newFcmToken};
            }
            return p.toJson();
          }).toList();

      if (isTokenNotUpdated) return;

      // Update the chat document with new participant data
      await _firestore
          .collection(FirebaseCollections.chats)
          .doc(params.chatId)
          .update({'participant': updatedParticipants});
    } catch (e, stack) {
      CrashlyticsService.recordError(e, stack);
      throw ServerFailure();
    }
  }
  @override
  Future<void> updateDisplayName(UpdateDisplayNameParams params) async {
    try {
      bool isDisplayNameUpdated = false;
      final updatedParticipants =
          params.participant.map((p) {
            if (p.id != params.userId) {
              if (p.displayName == params.newDisplayName) {
                isDisplayNameUpdated = true;
              }
              return {...p.toJson(), 'displayName': params.newDisplayName};
            }
            return p.toJson();
          }).toList();

      if (isDisplayNameUpdated) return;

      // Update the chat document
      await _firestore
          .collection(FirebaseCollections.chats)
          .doc(params.chatId)
          .update({'participant': updatedParticipants});
    } catch (e, stack) {
      CrashlyticsService.recordError(e, stack);
      throw ServerFailure();
    }
  }
}
