import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validation_utils.dart';
import '../../domain/entities/auth_session.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/phone_auth_bloc.dart';
import '../widgets/phone_input_field.dart';

class LoginScreen extends StatelessWidget {
  /// Optionally inject a [PhoneAuthBloc] (used in widget tests).
  final PhoneAuthBloc? phoneAuthBloc;

  const LoginScreen({super.key, this.phoneAuthBloc});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => phoneAuthBloc ?? GetIt.I<PhoneAuthBloc>(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  int _selectedTab = 0; // 0 = Email, 1 = Numéro

  // Email form
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  // Phone form
  final _phoneController = TextEditingController();
  bool _isPhoneValid = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String get _cleanPhone => _phoneController.text.replaceAll(' ', '');

  void _handleForgotPassword() {
    final email = _emailController.text.trim();
    showDialog(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController(text: email);
        return AlertDialog(
          backgroundColor: AppColors.cardDark,
          title: const Text(
            'Mot de passe oublié',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Entrez votre email pour recevoir un lien de réinitialisation.',
                style: TextStyle(color: AppColors.textGrey, fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'votre@email.com',
                  prefixIcon: Icon(Icons.email_outlined, size: 20),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                final mail = controller.text.trim();
                if (mail.isNotEmpty) {
                  context.read<AuthBloc>().add(
                    ResetPasswordRequested(email: mail),
                  );
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Email de réinitialisation envoyé à $mail'),
                      backgroundColor: AppColors.primary,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Text('Envoyer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is Authenticated) {
              context.go('/home');
            } else if (state is EmailNotRegistered) {
              context.push('/signup', extra: <String, String?>{'email': state.email});
            } else if (state is GoogleNewUser) {
              context.push('/signup', extra: <String, String?>{
                'email': state.email,
                'name': state.name,
              });
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
        ),
        BlocListener<PhoneAuthBloc, PhoneAuthState>(
          listener: (context, state) {
            if (state is OtpSentSuccess) {
              context.push('/otp-verification', extra: {
                'phone': state.phone,
                'formattedPhone': state.formattedPhone,
              });
            } else if (state is PhoneNotRegistered) {
              context.push('/signup', extra: <String, String?>{'phone': state.phone});
            } else if (state is PhoneAuthError) {
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
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),

                // ── Header inline ──
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => context.canPop() ? context.pop() : context.go('/home'),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Text.rich(
                  const TextSpan(
                    children: [
                      TextSpan(
                        text: 'BOUCHERIE',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      TextSpan(
                        text: ' EXPRESS',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Connectez-vous pour commander,\nsuivre et gérer vos favoris.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // ── Toggle Email / Numéro ──
                _TabToggle(
                  selectedTab: _selectedTab,
                  onTabChanged: (tab) => setState(() => _selectedTab = tab),
                ),

                const SizedBox(height: 32),

                // ── Contenu conditionnel ──
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) =>
                      FadeTransition(opacity: animation, child: child),
                  child: _selectedTab == 0
                      ? _EmailTab(
                          key: const ValueKey('email'),
                          formKey: _formKey,
                          emailController: _emailController,
                          passwordController: _passwordController,
                          obscurePassword: _obscurePassword,
                          onTogglePassword: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          onForgotPassword: _handleForgotPassword,
                          onSwitchToPhone: () =>
                              setState(() => _selectedTab = 1),
                        )
                      : _PhoneTab(
                          key: const ValueKey('phone'),
                          phoneController: _phoneController,
                          isPhoneValid: _isPhoneValid,
                          onPhoneChanged: (v) => setState(
                            () => _isPhoneValid = PhoneInputField.isValid(v),
                          ),
                          cleanPhone: _cleanPhone,
                        ),
                ),

                const SizedBox(height: 32),

                // ── Lien inscription ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Pas encore inscrit ?',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/signup'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        "S'inscrire",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Toggle pill ────────────────────────────────────────────────────────────

class _TabToggle extends StatelessWidget {
  final int selectedTab;
  final ValueChanged<int> onTabChanged;

  const _TabToggle({required this.selectedTab, required this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _TabButton(
            label: 'E-mail',
            index: 0,
            selectedTab: selectedTab,
            onTap: onTabChanged,
          ),
          _TabButton(
            label: 'Numéro',
            index: 1,
            selectedTab: selectedTab,
            onTap: onTabChanged,
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final int index;
  final int selectedTab;
  final ValueChanged<int> onTap;

  const _TabButton({
    required this.label,
    required this.index,
    required this.selectedTab,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected
                  ? AppColors.backgroundDark
                  : AppColors.textSecondary,
              fontWeight:
                  isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Tab Email ──────────────────────────────────────────────────────────────

class _EmailTab extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onForgotPassword;
  final VoidCallback onSwitchToPhone;

  const _EmailTab({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onTogglePassword,
    required this.onForgotPassword,
    required this.onSwitchToPhone,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            validator: ValidationUtils.validateEmail,
            decoration: const InputDecoration(
              hintText: 'Email',
              prefixIcon: Icon(Icons.email_outlined, size: 20),
            ),
          ),
          const SizedBox(height: 16),

          // Mot de passe
          TextFormField(
            controller: passwordController,
            obscureText: obscurePassword,
            validator: (value) => ValidationUtils.validatePassword(value),
            decoration: InputDecoration(
              hintText: 'Mot de passe',
              prefixIcon: const Icon(Icons.lock_outline, size: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                ),
                onPressed: onTogglePassword,
              ),
            ),
          ),

          // Mot de passe oublié
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onForgotPassword,
              child: const Text('Mot de passe oublié ?'),
            ),
          ),

          const SizedBox(height: 8),

          // Bouton CONNEXION
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final isLoading = state is AuthLoading;
              return SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          if (formKey.currentState!.validate()) {
                            context.read<AuthBloc>().add(
                              CheckEmailAndLogin(
                                email: emailController.text.trim(),
                                password: passwordController.text,
                              ),
                            );
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.backgroundDark,
                          ),
                        )
                      : const Text(
                          'CONNEXION',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                ),
              );
            },
          ),

          const SizedBox(height: 28),

          // Divider "Ou"
          Row(
            children: [
              Expanded(
                child: Divider(color: AppColors.border),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Ou',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
              Expanded(
                child: Divider(color: AppColors.border),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Icônes [123] et [G]
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Bouton téléphone [123]
              _IconAuthButton(
                onTap: onSwitchToPhone,
                child: const Text(
                  '123',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 24),
              // Bouton Google [G]
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  return _IconAuthButton(
                    onTap: state is AuthLoading
                        ? null
                        : () => context.read<AuthBloc>().add(
                              const SignInWithGoogleRequested(),
                            ),
                    child: const Text(
                      'G',
                      style: TextStyle(
                        color: Color(0xFF4285F4),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Tab Numéro ─────────────────────────────────────────────────────────────

class _PhoneTab extends StatelessWidget {
  final TextEditingController phoneController;
  final bool isPhoneValid;
  final ValueChanged<String> onPhoneChanged;
  final String cleanPhone;

  const _PhoneTab({
    super.key,
    required this.phoneController,
    required this.isPhoneValid,
    required this.onPhoneChanged,
    required this.cleanPhone,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PhoneInputField(
          controller: phoneController,
          onChanged: onPhoneChanged,
        ),
        const SizedBox(height: 32),
        BlocBuilder<PhoneAuthBloc, PhoneAuthState>(
          builder: (context, state) {
            final isLoading = state is OtpRequesting || state is PhoneChecking;
            return SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: (isPhoneValid && !isLoading)
                    ? () {
                        if (!AuthSession.isValidPhone(cleanPhone)) return;
                        context.read<PhoneAuthBloc>().add(
                          CheckPhoneAndLogin(phone: cleanPhone),
                        );
                      }
                    : null,
                child: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.backgroundDark,
                        ),
                      )
                    : const Text(
                        'Envoyer le code',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// ── Bouton icône circulaire ────────────────────────────────────────────────

class _IconAuthButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget child;

  const _IconAuthButton({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
        ),
        child: Center(child: child),
      ),
    );
  }
}
