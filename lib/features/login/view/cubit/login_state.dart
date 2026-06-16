import 'package:equatable/equatable.dart';

enum LoginStatus { initial, loading, success, failure }

class LoginState extends Equatable {
  const LoginState({
    this.status = LoginStatus.initial,
    this.email,
    this.errorMessage,
  });

  final LoginStatus status;
  final String? email;
  final String? errorMessage;

  LoginState copyWith({
    LoginStatus? status,
    String? email,
    String? errorMessage,
  }) {
    return LoginState(
      status: status ?? this.status,
      email: email ?? this.email,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, email, errorMessage];
}
