part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckIsAuthEvent extends AuthEvent {}

class SignInWithGoogleEvent extends AuthEvent {}

class SignInWithEmailAndPasswordEvent extends AuthEvent {
  final SignInParams params;

  const SignInWithEmailAndPasswordEvent(this.params);

  @override
  List<Object?> get props => [params];
}

class SignUpWithEmailAndPasswordEvent extends AuthEvent {
  final SignUpParams params;

  const SignUpWithEmailAndPasswordEvent(this.params);

  @override
  List<Object?> get props => [params];
}

class SignOutEvent extends AuthEvent {}
