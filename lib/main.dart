import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/cart/data/models/cart_item_model.dart';
import 'features/cart/presentation/bloc/cart_bloc.dart';
import 'features/favorites/presentation/bloc/favorites_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Charger le fichier d'environnement selon --dart-define=ENV=dev|staging|prod
  const env = String.fromEnvironment('ENV', defaultValue: 'dev');
  await dotenv.load(fileName: '.env.$env');

  // Initialize Firebase
  await Firebase.initializeApp();
  // Attendre que Firebase restaure la session persistante avant de lancer l'app.
  // Sans ce await, firebaseAuth.currentUser est null au démarrage même si l'utilisateur
  // est connecté, car la restauration depuis le stockage local est asynchrone.
  await FirebaseAuth.instance.authStateChanges().first;

  // Initialize Hive
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(CartItemModelAdapter());
  }

  // Initialize dependency injection
  await configureDependencies();

  // Initialize push notifications
  await getIt<NotificationService>().initialize();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<AuthBloc>()..add(CheckAuthStatus()),
        ),
        BlocProvider(create: (context) => getIt<CartBloc>()..add(LoadCart())),
        BlocProvider(
          create: (context) =>
              getIt<FavoritesBloc>()..add(const FavoritesLoadRequested()),
        ),
      ],
      child: const BoucherieExpressApp(),
    ),
  );
}

class BoucherieExpressApp extends StatelessWidget {
  const BoucherieExpressApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Boucherie Express',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
    );
  }
}
