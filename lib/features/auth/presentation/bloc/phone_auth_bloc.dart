import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/check_phone_exists.dart';
import '../../domain/usecases/request_otp.dart';
import '../../domain/usecases/resend_otp.dart';
import '../../domain/usecases/verify_otp.dart';

part 'phone_auth_event.dart';
part 'phone_auth_state.dart';

/// BLoC gérant le flux d'authentification téléphone + OTP.
///
/// Chaque écran crée sa propre instance via BlocProvider.
/// Le numéro est passé explicitement dans chaque événement.
@injectable
class PhoneAuthBloc extends Bloc<PhoneAuthEvent, PhoneAuthState> {
  final RequestOtp requestOtpUseCase;
  final VerifyOtp verifyOtpUseCase;
  final ResendOtp resendOtpUseCase;
  final CheckPhoneExists checkPhoneExistsUseCase;

  PhoneAuthBloc(
    this.requestOtpUseCase,
    this.verifyOtpUseCase,
    this.resendOtpUseCase,
    this.checkPhoneExistsUseCase,
  ) : super(PhoneAuthInitial()) {
    on<CheckPhoneAndLogin>(_onCheckPhoneAndLogin);
    on<SubmitPhoneNumber>(_onSubmitPhone);
    on<SubmitOtp>(_onSubmitOtp);
    on<RequestResendOtp>(_onResendOtp);
  }

  // ── Helpers ───────────────────────────────────────────────────────────

  static String formatPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'\s+'), '');
    if (cleaned.length != 10) return '+225 $phone';
    return '+225 ${cleaned.substring(0, 2)} ${cleaned.substring(2, 4)} '
        '${cleaned.substring(4, 6)} ${cleaned.substring(6, 8)} '
        '${cleaned.substring(8, 10)}';
  }

  // ── Handlers ──────────────────────────────────────────────────────────

  Future<void> _onCheckPhoneAndLogin(
    CheckPhoneAndLogin event,
    Emitter<PhoneAuthState> emit,
  ) async {
    // Skip backend check — it only knows Firebase Phone Auth UIDs, not
    // email-registered users who added a phone to their profile.
    // Firebase's isNewUser flag after OTP verification is the source of truth.
    emit(PhoneChecking());
    add(SubmitPhoneNumber(phone: event.phone));
  }

  Future<void> _onSubmitPhone(
    SubmitPhoneNumber event,
    Emitter<PhoneAuthState> emit,
  ) async {
    emit(OtpRequesting());

    final result = await requestOtpUseCase(
      RequestOtpParams(phone: event.phone),
    );

    result.fold(
      (failure) => emit(PhoneAuthError(message: failure.message)),
      (_) => emit(
        OtpSentSuccess(
          phone: event.phone,
          formattedPhone: formatPhone(event.phone),
        ),
      ),
    );
  }

  Future<void> _onSubmitOtp(
    SubmitOtp event,
    Emitter<PhoneAuthState> emit,
  ) async {
    emit(OtpVerifying());

    final result = await verifyOtpUseCase(
      VerifyOtpParams(phone: event.phone, code: event.code),
    );

    result.fold(
      (failure) {
        if (failure is PhoneNewUserFailure) {
          emit(PhoneNotRegistered(phone: failure.phone));
        } else {
          emit(PhoneAuthError(message: failure.message));
        }
      },
      (user) => emit(OtpVerifiedSuccess(user: user)),
    );
  }

  Future<void> _onResendOtp(
    RequestResendOtp event,
    Emitter<PhoneAuthState> emit,
  ) async {
    final result = await resendOtpUseCase(ResendOtpParams(phone: event.phone));

    result.fold(
      (failure) => emit(PhoneAuthError(message: failure.message)),
      (_) => emit(
        OtpResent(phone: event.phone, formattedPhone: formatPhone(event.phone)),
      ),
    );
  }
}
