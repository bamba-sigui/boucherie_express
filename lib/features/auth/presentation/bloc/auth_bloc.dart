import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/reset_password.dart';
import '../../domain/usecases/sign_in_with_email.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up_with_email.dart';
import '../../domain/usecases/save_fcm_token.dart';
import '../../domain/usecases/watch_auth_changes.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithEmail signInWithEmail;
  final SignUpWithEmail signUpWithEmail;
  final SignOut signOut;
  final GetCurrentUser getCurrentUser;
  final WatchAuthChanges watchAuthChanges;
  final SignInWithGoogle signInWithGoogle;
  final ResetPassword resetPassword;
  final SaveFcmToken saveFcmToken;
  StreamSubscription<User?>? _authSubscription;

  AuthBloc(
    this.signInWithEmail,
    this.signUpWithEmail,
    this.signOut,
    this.getCurrentUser,
    this.watchAuthChanges,
    this.signInWithGoogle,
    this.resetPassword,
    this.saveFcmToken,
  ) : super(AuthInitial()) {
    on<CheckEmailAndLogin>(_onCheckEmailAndLogin);
    on<SignInRequested>(_onSignInRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<AuthChanged>(_onAuthChanged);
    on<SignInWithGoogleRequested>(_onSignInWithGoogle);
    on<ResetPasswordRequested>(_onResetPassword);

    // Écoute les changements d'état Firebase (email, Google, téléphone)
    _authSubscription = watchAuthChanges().listen((user) {
      add(AuthChanged(user));
    });
  }

  Future<void> _onCheckEmailAndLogin(
    CheckEmailAndLogin event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await signInWithEmail(
      SignInParams(email: event.email, password: event.password),
    );
    result.fold(
      (failure) {
        // user-not-found → redirect to signup with pre-filled email
        if (failure is AuthFailure && failure.code == 'user-not-found') {
          emit(EmailNotRegistered(event.email));
        } else {
          emit(AuthError(failure.message));
        }
      },
      (user) {
        emit(Authenticated(user));
        saveFcmToken(); // ignore: unawaited_futures
      },
    );
  }

  Future<void> _onSignInRequested(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await signInWithEmail(
      SignInParams(email: event.email, password: event.password),
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) {
        emit(Authenticated(user));
        saveFcmToken(); // ignore: unawaited_futures
      },
    );
  }

  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await signUpWithEmail(
      SignUpParams(
        email: event.email,
        password: event.password,
        name: event.name,
        phone: event.phone,
      ),
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) {
        emit(Authenticated(user));
        saveFcmToken(); // ignore: unawaited_futures
      },
    );
  }

  Future<void> _onSignInWithGoogle(
    SignInWithGoogleRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await signInWithGoogle(NoParams());
    result.fold(
      (failure) {
        if (failure is NewGoogleUserFailure) {
          emit(GoogleNewUser(
            email: failure.email,
            name: failure.name,
            photoUrl: failure.photoUrl,
          ));
        } else {
          emit(AuthError(failure.message));
        }
      },
      (user) {
        emit(Authenticated(user));
        saveFcmToken(); // ignore: unawaited_futures
      },
    );
  }

  Future<void> _onResetPassword(
    ResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await resetPassword(ResetPasswordParams(email: event.email));
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const ResetPasswordSuccess('Email de réinitialisation envoyé')),
    );
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await signOut();
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(Unauthenticated()),
    );
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await getCurrentUser();
    result.fold(
      (failure) => emit(Unauthenticated()),
      (user) {
        if (user != null) {
          emit(Authenticated(user));
          saveFcmToken(); // ignore: unawaited_futures
        } else {
          emit(Unauthenticated());
        }
      },
    );
  }

  void _onAuthChanged(AuthChanged event, Emitter<AuthState> emit) {
    if (event.user != null) {
      emit(Authenticated(event.user!));
    } else {
      emit(Unauthenticated());
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
