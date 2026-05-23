import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:boucherie_express/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:boucherie_express/features/onboarding/presentation/screens/splash_screen.dart';
import 'package:boucherie_express/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:boucherie_express/features/home/presentation/screens/main_screen.dart';
import 'package:boucherie_express/features/cart/presentation/screens/cart_screen.dart';
import 'package:boucherie_express/features/favorites/presentation/pages/favorites_page.dart';
import 'package:boucherie_express/features/orders/presentation/screens/order_confirmation_screen.dart';
import 'package:boucherie_express/features/auth/presentation/screens/login_screen.dart';
import 'package:boucherie_express/features/auth/presentation/screens/signup_screen.dart';
import 'package:boucherie_express/features/auth/presentation/screens/otp_verification_screen.dart';
import 'package:boucherie_express/features/home/presentation/screens/product_details_screen.dart';
import 'package:boucherie_express/features/shared/domain/entities/product.dart';
import 'package:boucherie_express/features/cart/presentation/screens/checkout_screen.dart';
import 'package:boucherie_express/features/orders/domain/entities/order.dart';
import 'package:boucherie_express/features/orders/presentation/pages/order_details_page.dart';
import 'package:boucherie_express/features/orders/presentation/screens/order_tracking_screen.dart';
import 'package:boucherie_express/features/profile/presentation/screens/personal_info_screen.dart';
import 'package:boucherie_express/features/profile/presentation/screens/addresses_screen.dart';
import 'package:boucherie_express/features/profile/presentation/screens/payment_methods_screen.dart';
import 'package:boucherie_express/features/profile/presentation/screens/settings_screen.dart';
import 'package:boucherie_express/features/profile/presentation/screens/add_address_screen.dart';
import 'package:boucherie_express/features/profile/presentation/screens/edit_address_screen.dart';
import 'package:boucherie_express/features/profile/presentation/pages/support_page.dart';

/// Routes qui nécessitent d'être connecté
const _protectedRoutes = {
  '/order-confirmation',
  '/order-details',
  '/order-tracking',
  '/checkout',
  '/favorites',
  '/personal-info',
  '/addresses',
  '/payment-methods',
  '/support',
};

/// App router configuration
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final authState = context.read<AuthBloc>().state;
      final isAuthenticated = authState is Authenticated;
      final location = state.matchedLocation;

      // Rediriger vers /home si déjà authentifié et on tente d'aller sur login/signup
      final authRoutes = {'/login', '/signup', '/otp-verification'};
      if (isAuthenticated && authRoutes.contains(location)) {
        return '/home';
      }

      // Bloquer l'accès aux routes protégées si non connecté
      final isProtected = _protectedRoutes.any(
        (route) => location.startsWith(route),
      );
      if (isProtected && !isAuthenticated) {
        return '/login?redirect=${Uri.encodeComponent(location)}';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final tab = extra?['tab'] as int? ?? 0;
          return MainScreen(initialIndex: tab);
        },
      ),
      GoRoute(
        path: '/cart',
        name: 'cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) {
          final extra = state.extra as Map<String, String?>?;
          return SignupScreen(
            prefillEmail: extra?['email'],
            prefillPhone: extra?['phone'],
            prefillName: extra?['name'],
          );
        },
      ),
      GoRoute(
        path: '/details',
        name: 'details',
        builder: (context, state) {
          final product = state.extra as Product;
          return ProductDetailsScreen(product: product);
        },
      ),
      GoRoute(
        path: '/checkout',
        name: 'checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/order-confirmation',
        name: 'order-confirmation',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          return OrderConfirmationScreen(
            orderId: data['orderId'] as String,
            paymentMethodType: data['paymentMethodType'] as String,
          );
        },
      ),
      GoRoute(
        path: '/order-details',
        name: 'order-details',
        builder: (context, state) {
          final order = state.extra as Order;
          return OrderDetailsPage(order: order);
        },
      ),
      GoRoute(
        path: '/favorites',
        builder: (context, state) => const FavoritesPage(),
      ),
      GoRoute(
        path: '/order-tracking',
        name: 'order-tracking',
        builder: (context, state) {
          final orderId = state.extra as String? ?? '';
          return OrderTrackingScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: '/personal-info',
        name: 'personal-info',
        builder: (context, state) => const PersonalInfoScreen(),
      ),
      GoRoute(
        path: '/addresses',
        name: 'addresses',
        builder: (context, state) => const AddressesScreen(),
      ),
      GoRoute(
        path: '/payment-methods',
        name: 'payment-methods',
        builder: (context, state) => const PaymentMethodsScreen(),
      ),
      GoRoute(
        path: '/support',
        name: 'support',
        builder: (context, state) => const SupportPage(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/addresses/add',
        name: 'add-address',
        builder: (context, state) => const AddAddressScreen(),
      ),
      GoRoute(
        path: '/addresses/:id/edit',
        name: 'edit-address',
        builder: (context, state) => EditAddressScreen(
          addressId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/otp-verification',
        name: 'otp-verification',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          return OtpVerificationScreen(
            phone: data['phone'] as String,
            formattedPhone: data['formattedPhone'] as String,
          );
        },
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Page non trouvée: ${state.uri}'))),
  );
}
