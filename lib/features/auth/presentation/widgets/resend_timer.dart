import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/auth_session.dart';

/// Timer de renvoi OTP avec compte à rebours.
///
/// Design Stitch (home_10) :
/// - Pendant le timer : icône schedule + « Renvoyer le code (00:XX) » primary
/// - Après : bouton actif « Renvoyer le code »
class ResendTimer extends StatefulWidget {
  final VoidCallback onResend;
  final int cooldownSeconds;

  const ResendTimer({
    super.key,
    required this.onResend,
    this.cooldownSeconds = AuthSession.resendCooldownSeconds,
  });

  @override
  State<ResendTimer> createState() => ResendTimerState();
}

class ResendTimerState extends State<ResendTimer> {
  late int _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = widget.cooldownSeconds;
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining <= 1) {
        timer.cancel();
        setState(() => _remaining = 0);
      } else {
        setState(() => _remaining--);
      }
    });
  }

  /// Réinitialise le timer (appelé après renvoi réussi).
  void reset() {
    setState(() => _remaining = widget.cooldownSeconds);
    _startTimer();
  }

  String _formatTime(int seconds) {
    final min = (seconds ~/ 60).toString().padLeft(2, '0');
    final sec = (seconds % 60).toString().padLeft(2, '0');
    return '$min:$sec';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Vous n\'avez pas reçu de code ?',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: _remaining == 0
              ? () {
                  widget.onResend();
                  reset();
                }
              : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.schedule_rounded,
                color: _remaining > 0
                    ? AppColors.textSecondary
                    : AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  color: _remaining > 0
                      ? AppColors.textSecondary
                      : AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                child: Text(
                  _remaining > 0
                      ? 'Renvoyer le code (${_formatTime(_remaining)})'
                      : 'Renvoyer le code',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
