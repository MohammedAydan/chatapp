import 'package:chatapp/core/connection/network_info.dart';
import 'package:chatapp/core/database/cache/cache_helper.dart';
import 'package:chatapp/core/services/locale_service.dart';
import 'package:chatapp/core/services/theme_service.dart';
import 'package:chatapp/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:chatapp/features/auth/data/repositories/auth_respository_impl.dart';
import 'package:chatapp/features/auth/domain/repositories/auth_respository.dart';
import 'package:chatapp/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:chatapp/features/auth/domain/usecases/sign_in_with_email_and_password_usecase.dart';
import 'package:chatapp/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:chatapp/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:chatapp/features/auth/domain/usecases/sign_up_with_email_and_password_usecase.dart';
import 'package:chatapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chatapp/features/chat/data/datasource/chat_local_datasource.dart';
import 'package:chatapp/features/chat/data/datasource/chat_remote_datasource.dart';
import 'package:chatapp/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:chatapp/features/chat/domain/repositories/chat_repository.dart';
import 'package:chatapp/features/chat/domain/usecases/get_chat_messages_from_local_as_stream_usecase.dart';
import 'package:chatapp/features/chat/domain/usecases/get_chat_messages_from_local_usecase.dart';
import 'package:chatapp/features/chat/domain/usecases/get_chat_messages_usecase.dart';
import 'package:chatapp/features/chat/domain/usecases/remove_chat_message_usecase.dart';
import 'package:chatapp/features/chat/domain/usecases/save_chat_messages_local_usecase.dart';
import 'package:chatapp/features/chat/domain/usecases/send_chat_message_usecase.dart';
import 'package:chatapp/features/chat/domain/usecases/set_chat_messages_read_usecase.dart';
import 'package:chatapp/features/home/data/datasource/chats_local_datasource.dart';
import 'package:chatapp/features/home/data/datasource/chats_remote_datasource.dart';
import 'package:chatapp/features/home/data/repositories/chats_repository_impl.dart';
import 'package:chatapp/features/home/domain/repositories/chats_repository.dart';
import 'package:chatapp/features/home/domain/usecases/create_chat_usecase.dart';
import 'package:chatapp/features/home/domain/usecases/get_chats_local_usecase.dart';
import 'package:chatapp/features/home/domain/usecases/get_chats_usecase.dart';
import 'package:chatapp/features/home/domain/usecases/remove_chat_usecase.dart';
import 'package:chatapp/features/home/domain/usecases/save_chats_usecase.dart';
import 'package:chatapp/features/home/domain/usecases/update_display_name_usecase.dart';
import 'package:chatapp/features/home/domain/usecases/update_fcm_token_usecase.dart';
import 'package:chatapp/features/home/presentation/blocs/chats/chats_bloc.dart';
import 'package:chatapp/features/home/presentation/blocs/chats_actions/chats_actions_bloc.dart';
import 'package:chatapp/global/blocs/locale/locale_bloc.dart';
import 'package:chatapp/global/blocs/network/network_bloc.dart';
import 'package:chatapp/global/blocs/theme/theme_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_connection_checker_tv/data_connection_checker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';

final sl = GetIt.instance;

Future<void> init() async {
  await GetStorage.init();

  // services
  sl.registerLazySingleton(() => FirebaseMessaging.instance);
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);

  // global blocs
  sl.registerLazySingleton(() => NetworkBloc(networkInfo: sl()));
  sl.registerLazySingleton(() => ThemeBloc(themeService: sl()));
  sl.registerLazySingleton(() => LocaleBloc(localeService: sl()));

  // blocs
  // Auth Feature
  sl.registerLazySingleton(
    () => AuthBloc(
      getCurrentUserUsecase: sl(),
      signInWithGoogle: sl(),
      signInWithEmailAndPasswordUsecase: sl(),
      signUpWithEmailAndPasswordUsecase: sl(),
      signOutUsecase: sl(),
    ),
  );
  // Home | Chats Feature
  sl.registerLazySingleton(
    () => ChatsBloc(
      getChatsUsecase: sl(),
      getChatsLocalUsecase: sl(),
      saveChatsUsecase: sl(),
      updateFcmTokenUsecase: sl(),
    ),
  );
    sl.registerLazySingleton(
    () => ChatsActionsBloc(
      createChatUsecase: sl(),
      updateDisplayNameUsecase: sl(),
      removeChatUsecase: sl(),
    ),
  );
  // Chat Feature
  // sl.registerLazySingleton(
  //   () => ChatBloc(
  //     getChatMessageUsecase: sl(),
  //     sendChatMessageUsecase: sl(),
  //     removeChatMessageUsecase: sl(),
  //     getChatMessageFromLocalUsecase: sl(),
  //     setChatMessagesReadUsecase: sl(),
  //   ),
  // );

  // use cases
  // Auth Feature
  sl.registerLazySingleton(() => GetCurrentUserUsecase(sl()));
  sl.registerLazySingleton(() => SignInWithGoogleUsecase(sl()));
  sl.registerLazySingleton(() => SignInWithEmailAndPasswordUsecase(sl()));
  sl.registerLazySingleton(() => SignUpWithEmailAndPasswordUsecase(sl()));
  sl.registerLazySingleton(() => SignOutUsecase(sl()));
  // Home | Chats Feature
  sl.registerLazySingleton(() => GetChatsUsecase(sl()));
  sl.registerLazySingleton(() => GetChatsLocalUsecase(sl()));
  sl.registerLazySingleton(() => SaveChatsUsecase(sl()));
  sl.registerLazySingleton(() => CreateChatUsecase(sl()));
  sl.registerLazySingleton(() => RemoveChatUsecase(sl()));
  sl.registerLazySingleton(() => UpdateDisplayNameUsecase(sl()));
  sl.registerLazySingleton(() => UpdateFcmTokenUsecase(sl()));
  // Chat Feature
  sl.registerLazySingleton(() => GetChatMessagesUsecase(sl()));
  sl.registerLazySingleton(() => SendChatMessageUsecase(sl()));
  sl.registerLazySingleton(() => SaveChatMessagesLocalUsecase(sl()));
  sl.registerLazySingleton(() => RemoveChatMessageUsecase(sl()));
  sl.registerLazySingleton(() => GetChatMessagesFromLocalUsecase(sl()));
  sl.registerLazySingleton(() => SetChatMessagesReadUsecase(sl()));
  sl.registerLazySingleton(() => GetChatMessagesFromLocalAsStreamUsecase(sl()));

  // repositories
  // Auth Feature
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl(), sl()),
  );
  // Home | Chats Feature
  sl.registerLazySingleton<ChatsRepository>(
    () => ChatsRepositoryImpl(sl(), sl(), sl()),
  );
  // Chat Feature
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(sl(), sl(), sl()),
  );

  // datasource
  // Auth Feature
  sl.registerLazySingleton<AuthRemoteDatasource>(
    () => AuthRemoteDatasourceImpl(sl(), sl(), sl()),
  );
  // Home | Chats Feature
  sl.registerLazySingleton<ChatsRemoteDataSource>(
    () => ChatsRemoteDataSourceImpl(sl(), sl()),
  );
  sl.registerLazySingleton<ChatsLocalDataSource>(
    () => ChatsLocalDataSourceImpl(sl()),
  );
  // Chat Feature
  sl.registerLazySingleton<ChatRemoteDatasource>(
    () => ChatRemoteDatasourceImpl(sl()),
  );
  sl.registerLazySingleton<ChatLocalDatasource>(
    () => ChatLocalDatasourceImpl(sl()),
  );

  // core
  sl.registerLazySingleton(() => DataConnectionChecker());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton<GetStorage>(() => GetStorage());
  sl.registerLazySingleton<CacheHelper>(() => CacheHelper(sl()));
  sl.registerLazySingleton<ThemeService>(() => ThemeServiceImpl(sl()));
  sl.registerLazySingleton<LocaleService>(() => LocaleServiceImpl(sl()));
}
