import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/auth_session.dart';
import '../bloc/phone_auth_bloc.dart';
import '../widgets/otp_input.dart';
import '../widgets/resend_timer.dart';

/// Écran de vérification OTP.
///
/// Design Stitch (boucherie_express_home_10) :
/// - Header sticky : ← VÉRIFICATION
/// - Icône phonelink_lock dans cercle primary/10
/// - Titre « Vérifier votre numéro »
/// - Sous-titre « Code envoyé au +225 XX XX XX XX XX »
/// - 4 champs OTP
/// - Timer de renvoi (45 s)
/// - Bouton « Vérifier » (primary, full-width)
class OtpVerificationScreen extends StatelessWidget {
  final String phone;
  final String formattedPhone;

  /// Optionally inject a [PhoneAuthBloc] (used in widget tests).
  final PhoneAuthBloc? phoneAuthBloc;

  const OtpVerificationScreen({
    super.key,
    required this.phone,
    required this.formattedPhone,
    this.phoneAuthBloc,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => phoneAuthBloc ?? GetIt.I<PhoneAuthBloc>(),
      child: _OtpVerificationView(phone: phone, formattedPhone: formattedPhone),
    );
  }
}

class _OtpVerificationView extends StatefulWidget {
  final String phone;
  final String formattedPhone;

  const _OtpVerificationView({
    required this.phone,
    required this.formattedPhone,
  });

  @override
  State<_OtpVerificationView> createState() => _OtpVerificationViewState();
}

class _OtpVerificationViewState extends State<_OtpVerificationView> {
  final _otpKey = GlobalKey<OtpInputState>();
  final _resendKey = GlobalKey<ResendTimerState>();
  String _currentCode = '';
  bool _hasError = false;

  bool get _isOtpComplete => AuthSession.isOtpComplete(_currentCode);

  void _onOtpCompleted(String code) {
    setState(() {
      _currentCode = code;
      _hasError = false;
    });
  }

  void _onOtpChanged(String code) {
    setState(() {
      _currentCode = code;
      if (_hasError) _hasError = false;
    });
  }

  void _submitOtp() {
    if (!_isOtpComplete) return;
    context.read<PhoneAuthBloc>().add(
      SubmitOtp(phone: widget.phone, code: _currentCode),
    );
  }

  void _resendOtp() {
    context.read<PhoneAuthBloc>().add(RequestResendOtp(phone: widget.phone));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PhoneAuthBloc, PhoneAuthState>(
      listener: (context, state) {
        if (state is OtpVerifiedSuccess) {
          // Succès → Home
          context.go('/home');
        } else if (state is OtpResent) {
          // OTP renvoyé → reset timer + feedback
          _resendKey.currentState?.reset();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Code renvoyé avec succès'),
              backgroundColor: AppColors.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        } else if (state is PhoneAuthError) {
          // Erreur → feedback visuel + vibration
          setState(() => _hasError = true);
          _otpKey.currentState?.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: Column(
          children: [
            // ── Sticky header ──
            ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 8,
                    bottom: 16,
                    left: 20,
                    right: 20,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundDark.withValues(alpha: .9),
                    border: const Border(
                      bottom: BorderSide(color: AppColors.border),
                    ),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.maybePop(context),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: AppColors.textPrimary,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'VÉRIFICATION',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Content ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 48),

                    // Icon illustration
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: .1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: .2),
                        ),
                      ),
                      child: const Icon(
                        Icons.phonelink_lock_rounded,
                        color: AppColors.primary,
                        size: 48,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Title
                    const Text(
                      'Vérifier votre numéro',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Subtitle with phone number
                    Text.rich(
                      TextSpan(
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        children: [
                          const TextSpan(text: 'Entrez le code envoyé au\n'),
                          TextSpan(
                            text: widget.formattedPhone,
                            style: const TextStyle(color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 40),

                    // OTP Input
                    OtpInput(
                      key: _otpKey,
                      onCompleted: _onOtpCompleted,
                      onChanged: _onOtpChanged,
                      hasError: _hasError,
                    ),

                    const SizedBox(height: 32),

                    // Resend timer
                    ResendTimer(key: _resendKey, onResend: _resendOtp),

                    const SizedBox(height: 48),

                    // Verify button
                    BlocBuilder<PhoneAuthBloc, PhoneAuthState>(
                      builder: (context, state) {
                        final isLoading = state is OtpVerifying;

                        return SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: (_isOtpComplete && !isLoading)
                                ? _submitOtp
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.backgroundDark,
                              disabledBackgroundColor: AppColors.primary
                                  .withValues(alpha: .3),
                              disabledForegroundColor: AppColors.backgroundDark
                                  .withValues(alpha: .5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: AppColors.backgroundDark,
                                    ),
                                  )
                                : const Text(
                                    'VÉRIFIER',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
