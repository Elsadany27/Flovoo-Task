import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/session_service.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit({required SessionService sessionService})
      : _sessionService = sessionService,
        super(const LoginState());

  final SessionService _sessionService;

  Future<void> login(String rawEmail) async {
    final email = rawEmail.trim().toLowerCase();

    emit(state.copyWith(status: LoginStatus.loading, errorMessage: null));

    try {
      await _sessionService.saveEmail(email);
      emit(
        state.copyWith(
          status: LoginStatus.success,
          email: email,
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: 'Could not sign in. Please try again.',
        ),
      );
    }
  }
}
