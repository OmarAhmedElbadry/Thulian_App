import "package:flutter_bloc/flutter_bloc.dart";

import "../../domain/auth_failure.dart";
import "../../domain/repositories/auth_repository.dart";

enum AuthActionStatus { idle, submitting, success, failure }

class AuthState {
  const AuthState({this.status = AuthActionStatus.idle, this.message});

  final AuthActionStatus status;
  final String? message;
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(const AuthState());

  final AuthRepository _repository;

  Future<void> signIn({required String email, required String password}) =>
      _run(() => _repository.signInWithEmail(email: email, password: password));

  Future<void> createAccount({
    required String name,
    required String email,
    required String password,
  }) => _run(
    () =>
        _repository.createAccount(name: name, email: email, password: password),
  );

  Future<void> signInWithGoogle() => _run(_repository.signInWithGoogle);

  Future<void> sendPasswordResetEmail(String email) =>
      _run(() => _repository.sendPasswordResetEmail(email));

  Future<void> signOut() => _run(_repository.signOut);

  void reset() => emit(const AuthState());

  Future<void> _run(Future<void> Function() action) async {
    emit(const AuthState(status: AuthActionStatus.submitting));
    try {
      await action();
      emit(const AuthState(status: AuthActionStatus.success));
    } on AuthFailure catch (error) {
      emit(AuthState(status: AuthActionStatus.failure, message: error.message));
    } catch (_) {
      emit(
        const AuthState(
          status: AuthActionStatus.failure,
          message: "We couldn't complete that request. Please try again.",
        ),
      );
    }
  }
}
