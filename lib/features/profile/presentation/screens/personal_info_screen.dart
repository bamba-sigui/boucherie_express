import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/personal_info_bloc.dart';
import '../widgets/profile_avatar_section.dart';
import '../widgets/profile_details_header.dart';
import '../widgets/profile_input_field.dart';
import '../widgets/save_button.dart';

/// Écran Informations personnelles — design Stitch (home_2).
///
/// Permet de consulter et modifier nom, téléphone, email.
/// Utilise [PersonalInfoBloc] pour la gestion d'état (chargement,
/// détection de changements, validation, sauvegarde).
class PersonalInfoScreen extends StatelessWidget {
  const PersonalInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PersonalInfoBloc>()..add(LoadPersonalInfo()),
      child: const _PersonalInfoView(),
    );
  }
}

class _PersonalInfoView extends StatelessWidget {
  const _PersonalInfoView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: BlocConsumer<PersonalInfoBloc, PersonalInfoState>(
        listener: (context, state) {
          if (state is PersonalInfoSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.backgroundDark,
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Profil mis à jour avec succès',
                      style: TextStyle(
                        color: AppColors.backgroundDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                backgroundColor: AppColors.primary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(16),
                duration: const Duration(seconds: 2),
              ),
            );
            // Retour vers le profil après un court délai
            Future.delayed(const Duration(milliseconds: 800), () {
              if (context.mounted) context.pop();
            });
          }

          if (state is PersonalInfoError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: AppColors.textPrimary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
                backgroundColor: AppColors.accentRed,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(16),
              ),
            );
          }
        },
        builder: (context, state) {
          // --- Loading ---
          if (state is PersonalInfoLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          // --- Loaded / Editing ---
          if (state is PersonalInfoLoaded) {
            return _buildContent(context, state);
          }

          // --- Fallback (Initial / Error) ---
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, PersonalInfoLoaded state) {
    final bloc = context.read<PersonalInfoBloc>();

    return GestureDetector(
      // Masquer le clavier au tap extérieur
      onTap: () => FocusScope.of(context).unfocus(),
      child: Stack(
        children: [
          // Contenu scrollable
          SingleChildScrollView(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 72,
              left: 20,
              right: 20,
              bottom: 32,
            ),
            child: Column(
              children: [
                const SizedBox(height: 16),

                // — Avatar —
                ProfileAvatarSection(
                  photoUrl: state.user.photoUrl,
                  onChangePhoto: () async {
                    final file = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 80,
                    );
                    if (file != null && context.mounted) {
                      context
                          .read<PersonalInfoBloc>()
                          .add(UploadAvatarRequested(file));
                    }
                  },
                ),
                const SizedBox(height: 32),

                // — Champ Nom complet —
                ProfileInputField(
                  label: 'Nom complet',
                  placeholder: 'Votre nom',
                  icon: Icons.person_rounded,
                  initialValue: state.editedName,
                  keyboardType: TextInputType.name,
                  errorText: state.nameError,
                  onChanged: (value) =>
                      bloc.add(FieldChanged(fieldName: 'name', value: value)),
                ),
                const SizedBox(height: 24),

                // — Champ Téléphone —
                ProfileInputField(
                  label: 'Numéro de téléphone',
                  placeholder: '+225 07 08 09 10 11',
                  icon: Icons.call_rounded,
                  initialValue: state.editedPhone,
                  keyboardType: TextInputType.phone,
                  readOnly: true, // Modifiable uniquement via vérification OTP
                  onChanged: (value) =>
                      bloc.add(FieldChanged(fieldName: 'phone', value: value)),
                ),
                const SizedBox(height: 24),

                // — Champ Email (optionnel) —
                ProfileInputField(
                  label: 'Email (Optionnel)',
                  placeholder: 'exemple@email.com',
                  icon: Icons.mail_rounded,
                  initialValue: state.editedEmail,
                  keyboardType: TextInputType.emailAddress,
                  errorText: state.emailError,
                  onChanged: (value) =>
                      bloc.add(FieldChanged(fieldName: 'email', value: value)),
                ),
                const SizedBox(height: 48),

                // — Bouton sauvegarder —
                SaveButton(
                  enabled: state.hasChanges,
                  isLoading: state.isSaving,
                  onPressed: () => bloc.add(SavePersonalInfo()),
                ),
                const SizedBox(height: 20),

                // — Mention de confidentialité —
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Vos données sont sécurisées et ne seront pas partagées '
                    'avec des tiers conformément à notre politique de confidentialité.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      height: 1.6,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // — Header sticky —
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ProfileDetailsHeader(onBack: () => context.pop()),
          ),
        ],
      ),
    );
  }
}
