import 'dart:convert';
import 'package:chatapp/core/database/cache/cache_helper.dart';
import 'package:chatapp/core/params/get_chats_params.dart';
import 'package:chatapp/features/home/data/models/chat_model.dart';
import 'package:chatapp/features/home/domain/entities/chat_entity.dart';
import 'package:chatapp/core/services/crashlytics_service.dart';

abstract class ChatsLocalDataSource {
  Future<void> cacheChats(List<ChatEntity> chats, String userId);
  Future<List<ChatEntity>> getCachedChats(GetChatsParams params);
}

const cachedChatsKey = 'CACHED_CHATS_';

class ChatsLocalDataSourceImpl implements ChatsLocalDataSource {
  final CacheHelper _cacheHelper;

  ChatsLocalDataSourceImpl(this._cacheHelper);

  @override
  Future<void> cacheChats(List<ChatEntity> chats, String userId) async {
    try {
      final List<Map<String, dynamic>> serializableList = [];

      for (final chat in chats) {
        final Map<String, dynamic> chatMap = chat.toJson();

        if (chatMap.containsKey('participant')) {
          if (chatMap['participant'] is Iterable) {
            final participantList =
                (chatMap['participant'] as Iterable)
                    .map((participant) {
                      if (participant is Map) {
                        return participant;
                      } else if (participant != null) {
                        try {
                          return participant.toJson();
                        } catch (_) {
                          return {'id': participant.toString()};
                        }
                      }
                      return null;
                    })
                    .where((item) => item != null)
                    .toList();

            chatMap['participant'] = participantList;
          }
        }

        _ensureSerializable(chatMap);

        serializableList.add(chatMap);
      }

      final String encodedJson = json.encode(serializableList);

      await _cacheHelper.save(cachedChatsKey + userId, encodedJson);
    } catch (e, stack) {
      CrashlyticsService.recordError(e, stack);
      throw Exception('Failed to cache chats: ${e.toString()}');
    }
  }

  void _ensureSerializable(Map<String, dynamic> map) {
    map.forEach((key, value) {
      if (value is Iterable) {
        map[key] = value.toList();
      } else if (value is Map) {
        _ensureSerializable(value as Map<String, dynamic>);
      }
    });
  }

  @override
  Future<List<ChatEntity>> getCachedChats(GetChatsParams params) async {
    try {
      final cachedData = await _cacheHelper.read(
        cachedChatsKey + params.userId,
      );

      if (cachedData == null) {
        return [];
      }

      final List<dynamic> jsonList = json.decode(cachedData.toString());

      return jsonList.map((item) => ChatModel.fromJson(item)).toList();
    } catch (e, stack) {
      CrashlyticsService.recordError(e, stack);
      print('Error retrieving cached chats: ${e.toString()}');
      return [];
    }
  }
}
