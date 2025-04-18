import 'package:chatapp/core/errors/errors.dart';
import 'package:chatapp/core/params/get_chat_message_params.dart';
import 'package:chatapp/core/params/remove_chat_message_params.dart';
import 'package:chatapp/core/params/send_chat_message_params.dart';
import 'package:chatapp/core/params/set_chat_messages_read_params.dart';
import 'package:chatapp/core/services/push_notification_service.dart';
import 'package:chatapp/core/strings/firebase_collections.dart';
import 'package:chatapp/core/utils/create_chat_id.dart';
import 'package:chatapp/features/home/data/models/chat_message_model.dart';
import 'package:chatapp/features/home/data/models/chat_model.dart';
import 'package:chatapp/features/home/domain/entities/chat_message_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatapp/core/services/crashlytics_service.dart';

abstract class ChatRemoteDatasource {
  Stream<List<ChatMessageEntity>> getChatMessages(GetChatMessageParams params);
  Future<void> sendChatMessages(SendChatMessageParams params);
  Future<void> removeChatMessage(RemoveChatMessageParams params);
  Future<void> setChatMessagesRead(SetChatMessagesReadParams params);
}

class ChatRemoteDatasourceImpl implements ChatRemoteDatasource {
  final FirebaseFirestore _firestore;

  ChatRemoteDatasourceImpl(this._firestore);

  @override
  Stream<List<ChatMessageEntity>> getChatMessages(GetChatMessageParams params) {
    final chatId = createChatId(params.ids);
    try {
      return _firestore
          .collection(FirebaseCollections.chats)
          .doc(chatId)
          .collection(FirebaseCollections.messages)
          .orderBy("createdAt", descending: true)
          .limit(20)
          .snapshots()
          .handleError((error) {
            print(error);
            throw ServerFailure();
          })
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => ChatMessageModel.fromJson(doc.data()))
                .toList();
          });
    } catch (e, stack) {
      CrashlyticsService.recordError(e, stack);
      print(e);
      throw ServerFailure();
    }
  }

  @override
  Future<void> removeChatMessage(RemoveChatMessageParams params) async {
    try {
      // Create batch operation for atomic updates
      final batch = _firestore.batch();

      // Get references
      final messageRef = _firestore
          .collection(FirebaseCollections.chats)
          .doc(params.chatId)
          .collection(FirebaseCollections.messages)
          .doc(params.messageId);

      final chatRef = _firestore
          .collection(FirebaseCollections.chats)
          .doc(params.chatId);

      // Mark message as deleted
      batch.update(messageRef, {"isDeleted": true});

      // Get chat document to check last message
      final chatDoc = await chatRef.get();

      if (chatDoc.exists) {
        final chatModel = ChatModel.fromJson(chatDoc.data()!);

        // Update last message if needed
        if (chatModel.lastMessage.id == params.messageId) {
          batch.set(chatRef, {
            "lastMessage": {"isDeleted": true},
          }, SetOptions(merge: true));
        }

        // Commit all updates atomically
        await batch.commit();

        // Send push notification if message was unread
        if (!chatModel.lastMessage.isRead &&
            params.fcmToken?.isNotEmpty == true) {
          // old code
          // await PushNotificationService.sendNotification(
          //   token: params.fcmToken!,
          //   data: {
          //     "action": ActionsType.deletedMessage,
          //     "chatId": params.chatId,
          //     "messageId": params.messageId,
          //   },
          // );

          // new code
          await PushNotificationService.sendMessageNotification(
            params.fcmToken!,
            chatId: params.chatId,
            messageId: params.messageId,
            senderId: chatModel.lastMessage.senderId,
            title: chatModel.lastMessage.senderId,
            body: "",
            createdAt: chatModel.createdAt,
            isDeleted: true,
          );
        }
      }
    } catch (e, stack) {
      CrashlyticsService.recordError(e, stack);
      throw ServerFailure();
    }
  }

  @override
  Future<void> sendChatMessages(SendChatMessageParams params) async {
    try {
      final messageId =
          "${DateTime.now().millisecondsSinceEpoch}-${params.chatMessage.senderId}";

      // Prepare message data
      final messageData = {"id": messageId, ...params.chatMessage.toJson()};

      // Prepare last message data
      final lastMessageData = {"lastMessage": messageData};
      print(params.chatId);

      final batch = _firestore.batch();

      final messageRef = _firestore
          .collection(FirebaseCollections.chats)
          .doc(params.chatId)
          .collection(FirebaseCollections.messages)
          .doc(messageId);
      batch.set(messageRef, messageData);

      final chatRef = _firestore
          .collection(FirebaseCollections.chats)
          .doc(params.chatId);

      batch.update(chatRef, lastMessageData);

      await batch.commit();

      // old code
      // await PushNotificationService.sendNotification(
      //   token: params.fcmToken,
      //   data: {
      //     "action": ActionsType.addMessage,
      //     "chatId": params.chatId,
      //     "messageId": messageId,
      //   },
      // );

      // new code
      await PushNotificationService.sendMessageNotification(
        params.fcmToken,
        chatId: params.chatId,
        messageId: messageId,
        senderId: params.chatMessage.senderId,
        title: params.chatMessage.senderId,
        body: params.chatMessage.message,
        createdAt: params.chatMessage.createdAt,
      );
    } catch (e, stack) {
      CrashlyticsService.recordError(e, stack);
      throw ServerFailure();
    }
  }

  @override
  Future<void> setChatMessagesRead(SetChatMessagesReadParams params) async {
    try {
      final chatRef = _firestore
          .collection(FirebaseCollections.chats)
          .doc(params.chatId);

      final messagesRef = chatRef.collection(FirebaseCollections.messages);

      // 1. Get all unread messages
      final unreadMessages =
          await messagesRef
              .where("senderId", isNotEqualTo: params.senderId)
              .where('isRead', isEqualTo: false)
              .orderBy("createdAt", descending: true)
              .limit(20)
              .get();

      if (unreadMessages.docs.isEmpty) return;

      // 2. Create a batch
      final batch = _firestore.batch();

      for (final doc in unreadMessages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      // 3. Update lastMessage read status
      batch.set(chatRef, {
        'lastMessage': {'isRead': true},
      }, SetOptions(merge: true));

      // 4. Commit the batch
      await batch.commit();
    } catch (e, stack) {
      CrashlyticsService.recordError(e, stack);
      throw ServerFailure();
    }
  }
}
