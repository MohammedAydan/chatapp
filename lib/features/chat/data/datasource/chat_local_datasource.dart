import 'package:chatapp/core/database/cache/cache_helper.dart';
import 'package:chatapp/core/params/get_chat_message_params.dart';
import 'package:chatapp/core/utils/create_chat_id.dart';
import 'package:chatapp/features/home/data/models/chat_message_model.dart';
import 'package:chatapp/features/home/domain/entities/chat_message_entity.dart';
import 'package:chatapp/core/services/crashlytics_service.dart';

abstract class ChatLocalDatasource {
  Stream<List<ChatMessageEntity>> getChatMessagesAsStream(GetChatMessageParams params);
  List<ChatMessageEntity> getChatMessages(GetChatMessageParams params);
  Future<void> saveMessages(String chatId, List<ChatMessageEntity> messages);
}

class ChatLocalDatasourceImpl implements ChatLocalDatasource {
  final CacheHelper _cacheHelper;
  static const String _messagesKey = 'CHAT_MESSAGES';

  ChatLocalDatasourceImpl(this._cacheHelper);

  @override
  List<ChatMessageEntity> getChatMessages(GetChatMessageParams params) {
    try {
      final chatId = createChatId(params.ids);
      return _getMessagesForChat(chatId);
    } catch (e, stack) {
      CrashlyticsService.recordError(e, stack);
      return [];
    }
  }
  
  @override
  Stream<List<ChatMessageEntity>> getChatMessagesAsStream(GetChatMessageParams params) {
    try {
      final chatId = createChatId(params.ids);
      return Stream.value(_getMessagesForChat(chatId));
    } catch (e, stack) {
      CrashlyticsService.recordError(e, stack);
      return Stream.value([]);
    }
  }

  List<ChatMessageEntity> _getMessagesForChat(String chatId) {
    try {
      final messages = _cacheHelper.readData<List<dynamic>>(
        '$_messagesKey.$chatId',
      );
      if (messages == null || messages.isEmpty) return [];
      return messages
          .whereType<Map<String, dynamic>>()
          .map((m) => ChatMessageModel.fromJson(m))
          .toList();
    } catch (e, stack) {
      CrashlyticsService.recordError(e, stack);
      return [];
    }
  }

  @override
  Future<void> saveMessages(
    String chatId,
    List<ChatMessageEntity> messages,
  ) async {
    try {
      final messagesJson =
          messages.whereType<ChatMessageModel>().map((m) => m.toJson()).toList();

      await _cacheHelper.save('$_messagesKey.$chatId', messagesJson);
    } catch (e, stack) {
      CrashlyticsService.recordError(e, stack);
    }
  }
}
