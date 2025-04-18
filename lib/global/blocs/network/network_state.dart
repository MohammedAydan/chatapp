part of 'network_bloc.dart';

sealed class NetworkState extends Equatable {
  const NetworkState();
  
  @override
  List<Object> get props => [];
}

final class NetworkInitial extends NetworkState {}

final class NetworkLoadingState extends NetworkState {}

final class OfflineState extends NetworkState {}

final class OnlineState extends NetworkState {}