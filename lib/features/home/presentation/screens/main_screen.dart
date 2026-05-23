import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:boucherie_express/core/theme/app_colors.dart';
import 'package:boucherie_express/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:boucherie_express/features/home/domain/entities/product_filter.dart';
import 'package:boucherie_express/features/home/presentation/pages/filter_bottom_sheet.dart';
import 'package:boucherie_express/features/home/presentation/pages/home_page.dart';
import 'package:boucherie_express/features/home/presentation/widgets/custom_bottom_nav_bar.dart';
import 'package:boucherie_express/features/favorites/presentation/pages/favorites_page.dart';
import 'package:boucherie_express/features/orders/presentation/pages/orders_page.dart';
import 'package:boucherie_express/features/shared/domain/entities/product.dart';
import 'package:boucherie_express/features/profile/presentation/screens/profile_screen.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;
  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  late int _currentIndex = widget.initialIndex;
  final GlobalKey<HomePageState> _homeKey = GlobalKey();
  final GlobalKey<FavoritesPageState> _favoritesKey = GlobalKey();
  final GlobalKey<OrdersPageState> _ordersKey = GlobalKey();

  /// Filtre actuellement appliqué (pour pré-remplir le bottom sheet).
  ProductFilter _currentFilter = ProductFilter.defaultFilter;

  late final List<Widget> _screens = [
    HomePage(key: _homeKey),
    FavoritesPage(
      key: _favoritesKey,
      onNavigateToHome: () => setState(() => _currentIndex = 0),
    ),
    const SizedBox.shrink(), // Placeholder pour FILTRER (index 2)
    OrdersPage(
      key: _ordersKey,
      onNavigateToHome: () => setState(() => _currentIndex = 0),
    ),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Recharger les produits au retour en foreground
      _homeKey.currentState?.reloadProducts();
    }
  }

  void _onNavTap(int index) {
    if (index == 2) {
      // Bouton FILTRER central → ouvrir un BottomSheet de filtres
      _showFilterSheet();
      return;
    }

    // Mettre à jour les icônes favoris sur la home quand on y revient
    if (index == 0) {
      _homeKey.currentState?.refreshFavorites();
    }

    setState(() => _currentIndex = index);
  }

  void _showFilterSheet() async {
    // Le filtre n'est disponible que sur la page Home.
    if (_currentIndex != 0) return;

    final result = await FilterBottomSheet.show(
      context,
      currentFilter: _currentFilter,
    );

    if (result == null) return;

    if (result == 'reset') {
      // Réinitialiser les filtres.
      _currentFilter = ProductFilter.defaultFilter;
      _homeKey.currentState?.resetFilter();
    } else if (result is List<Product>) {
      // Appliquer les produits filtrés.
      _homeKey.currentState?.applyFilteredProducts(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          current is Authenticated && previous is! Authenticated,
      listener: (context, state) {
        setState(() => _currentIndex = 0);
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: IndexedStack(index: _currentIndex, children: _screens),
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: _currentIndex,
          onTap: _onNavTap,
          isFilterEnabled: _currentIndex == 0,
        ),
      ),
    );
  }
}
