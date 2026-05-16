import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/onboarding_page.dart';
import '../bloc/onboarding_bloc.dart';
import '../widgets/onboarding_page_widget.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = const [
    OnboardingPage(
      title: 'La viande fraîche,\nlivrée chez vous',
      description: "Directement depuis les éleveurs \nlocaux de Côte d'ivoire.",
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAgUVvi-7l09Mag6E4f_PsZhMo8FxXVJzWrerA-Dipj6GmAry_XlcolQ8h9i8DKziReWytYMzTzs0a2Vi_q1Nxbyjd6OM6UnUyQRGoVwGN74ZpQJj4GAU8_Eb4gPiLVVYENU4pCTfAM7TAyhv1cbImn7-4eP3bW2gd7DPTFqzPmDXaax1kLFvkqL-qA_3Mh81dcbfG6Zkzxp_4bnhGoalQTbTsWVDwqCreQkagvHbgRa9M9qJVyzhMX0AP67xlfp6X90XVvMcnIdw',
      badgeText: '100% Frais',
    ),
    OnboardingPage(
      title: 'Commandez et \nrecevez rapidement',
      description:
          'Paiement Mobile Money ou à la \nlivraison pour votre confort.',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAgUVvi-7l09Mag6E4f_PsZhMo8FxXVJzWrerA-Dipj6GmAry_XlcolQ8h9i8DKziReWytYMzTzs0a2Vi_q1Nxbyjd6OM6UnUyQRGoVwGN74ZpQJj4GAU8_Eb4gPiLVVYENU4pCTfAM7TAyhv1cbImn7-4eP3bW2gd7DPTFqzPmDXaax1kLFvkqL-qA_3Mh81dcbfG6Zkzxp_4bnhGoalQTbTsWVDwqCreQkagvHbgRa9M9qJVyzhMX0AP67xlfp6X90XVvMcnIdw',
      badgeText: '100% Frais',
    ),
    OnboardingPage(
      title: 'Simple, frais et \nsécurisé',
      description:
          'Une expérience d\'achat fluide pour vos \nproduits frais au quotidien.',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAgUVvi-7l09Mag6E4f_PsZhMo8FxXVJzWrerA-Dipj6GmAry_XlcolQ8h9i8DKziReWytYMzTzs0a2Vi_q1Nxbyjd6OM6UnUyQRGoVwGN74ZpQJj4GAU8_Eb4gPiLVVYENU4pCTfAM7TAyhv1cbImn7-4eP3bW2gd7DPTFqzPmDXaax1kLFvkqL-qA_3Mh81dcbfG6Zkzxp_4bnhGoalQTbTsWVDwqCreQkagvHbgRa9M9qJVyzhMX0AP67xlfp6X90XVvMcnIdw',
      badgeText: '100% Frais',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<OnboardingBloc>(),
      child: BlocListener<OnboardingBloc, OnboardingState>(
        listener: (context, state) {
          if (state is OnboardingCompleted) {
            // Navigate to home
            context.go('/home');
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.backgroundDark,
          body: SafeArea(
            child: Column(
              children: [
                // Header with logo
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.restaurant,
                          color: AppColors.backgroundDark,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Boucherie Express',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                // Page View
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return OnboardingPageWidget(page: _pages[index]);
                    },
                  ),
                ),

                // Bottom section with indicators and button
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Page indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _pages.length,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: index == _currentPage ? 32 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: index == _currentPage
                                  ? AppColors.primary
                                  : AppColors.border,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),

                      // Action button
                      Flexible(
                        child: Builder(
                          builder: (builderContext) {
                            final isLastPage =
                                _currentPage == _pages.length - 1;

                            return SizedBox(
                              height: 60,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (isLastPage) {
                                    builderContext.read<OnboardingBloc>().add(
                                      CompleteOnboardingEvent(),
                                    );
                                  } else {
                                    _pageController.nextPage(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      curve: Curves.easeInOut,
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.backgroundDark,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        isLastPage ? 'Commencer' : 'Suivant',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.arrow_forward),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
