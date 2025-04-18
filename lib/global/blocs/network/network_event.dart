part of 'network_bloc.dart';

sealed class NetworkEvent extends Equatable {
  const NetworkEvent();

  @override
  List<Object> get props => [];
}

class CheckNetworkEvent extends NetworkEvent {}

class NetworkChangedEvent extends NetworkEvent {
  final bool online;

  const NetworkChangedEvent({required this.online});

  @override
  List<Object> get props => [online];
}
