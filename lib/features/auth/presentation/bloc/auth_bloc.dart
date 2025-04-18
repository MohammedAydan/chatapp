// Updated clean architecture AuthBloc + Splash + SignInScreen
// Assuming all dependencies, usecases, entities, and routes are already defined and imported

import 'package:chatapp/core/params/sign_in_params.dart';
import 'package:chatapp/core/params/sign_up_params.dart';
import 'package:chatapp/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:chatapp/features/auth/domain/usecases/sign_in_with_email_and_password_usecase.dart';
import 'package:chatapp/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:chatapp/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:chatapp/features/auth/domain/usecases/sign_up_with_email_and_password_usecase.dart';
import 'package:chatapp/features/auth/domain/entities/user_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GetCurrentUserUsecase getCurrentUserUsecase;
  final SignInWithGoogleUsecase signInWithGoogle;
  final SignInWithEmailAndPasswordUsecase signInWithEmailAndPasswordUsecase;
  final SignUpWithEmailAndPasswordUsecase signUpWithEmailAndPasswordUsecase;
  final SignOutUsecase signOutUsecase;

  AuthBloc({
    required this.getCurrentUserUsecase,
    required this.signInWithGoogle,
    required this.signInWithEmailAndPasswordUsecase,
    required this.signUpWithEmailAndPasswordUsecase,
    required this.signOutUsecase,
  }) : super(AuthInitial()) {
    on<CheckIsAuthEvent>(_onCheckIsAuth);
    on<SignInWithGoogleEvent>(_signInWithGoogle);
    on<SignInWithEmailAndPasswordEvent>(_signInWithEmailAndPassword);
    on<SignUpWithEmailAndPasswordEvent>(_signUpWithEmailAndPassword);
    on<SignOutEvent>(_signOut);
  }

  Future<void> _onCheckIsAuth(
    CheckIsAuthEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await getCurrentUserUsecase();
    result.fold(
      (failure) => emit(AuthUnauthenticated()),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _signInWithGoogle(
    SignInWithGoogleEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await signInWithGoogle();
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _signInWithEmailAndPassword(
    SignInWithEmailAndPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await signInWithEmailAndPasswordUsecase(event.params);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _signUpWithEmailAndPassword(
    SignUpWithEmailAndPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await signUpWithEmailAndPasswordUsecase(event.params);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _signOut(SignOutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await signOutUsecase();
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(SignOut()),
    );
  }
}
