import 'dart:async';
import 'package:chatapp/core/connection/network_info.dart';
import 'package:data_connection_checker_tv/data_connection_checker.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'network_event.dart';
part 'network_state.dart';

class NetworkBloc extends Bloc<NetworkEvent, NetworkState> {
  final NetworkInfo networkInfo;
  StreamSubscription? _network;
  NetworkBloc({required this.networkInfo}) : super(NetworkInitial()) {
    on<CheckNetworkEvent>(_checkNetworkHandler);
    on<NetworkChangedEvent>(_networkChangedHandler);
  }

  void _checkNetworkHandler(CheckNetworkEvent event, Emitter emit) {
    try {
      _network?.cancel();
      _network = networkInfo.onStatusChange().listen((networkEvent) {
        add(
          NetworkChangedEvent(
            online: networkEvent == DataConnectionStatus.connected,
          ),
        );
      }, onError: (e) => emit(OfflineState()));
    } catch (e) {
      emit(OfflineState());
    }
  }

  void _networkChangedHandler(NetworkChangedEvent event, Emitter emit) {
    if (event.online) {
      emit(OnlineState());
    } else {
      emit(OfflineState());
    }
  }
}
