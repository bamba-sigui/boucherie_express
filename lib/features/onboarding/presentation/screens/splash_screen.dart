import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/splash_bloc.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<SplashBloc>()..add(CheckInitialStatus()),
      child: BlocListener<SplashBloc, SplashState>(
        listener: (context, state) {
          if (state is OnboardingRequired) {
            context.go('/onboarding');
          } else if (state is AuthenticatedState) {
            context.go('/home');
          } else if (state is UnauthenticatedState) {
            context.go('/home'); // Allow browsing as guest
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.backgroundDark,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.restaurant,
                    color: AppColors.backgroundDark,
                    size: 60,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Boucherie Express',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const CircularProgressIndicator(color: AppColors.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
