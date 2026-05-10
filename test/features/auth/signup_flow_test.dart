import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:boucherie_express/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:boucherie_express/features/auth/presentation/screens/signup_screen.dart';

import '../../helpers/auth_mocks.dart';

void main() {
  late FakeAuthBloc fakeAuthBloc;
  late GoRouter router;

  Widget buildSignup() {
    return BlocProvider<AuthBloc>.value(
      value: fakeAuthBloc,
      child: MaterialApp.router(routerConfig: router),
    );
  }

  setUp(() {
    fakeAuthBloc = FakeAuthBloc();
    router = GoRouter(
      initialLocation: '/signup',
      routes: [
        GoRoute(
          path: '/signup',
          builder: (_, __) => const SignupScreen(),
        ),
        GoRoute(path: '/login', builder: (_, __) => const Scaffold()),
        GoRoute(path: '/home', builder: (_, __) => const Scaffold()),
      ],
    );
  });

  tearDown(() async {
    await fakeAuthBloc.close();
    router.dispose();
  });

  /// Helper: scroll a widget into view and tap it.
  Future<void> scrollAndTap(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
  }

  group('SignupScreen — validation', () {
    testWidgets('empty form shows validation errors', (tester) async {
      await tester.pumpWidget(buildSignup());
      await tester.pumpAndSettle();

      final submitBtn = find.text("S'inscrire");
      await scrollAndTap(tester, submitBtn);
      await tester.pumpAndSettle();

      expect(find.text('Le nom est requis'), findsOneWidget);
      expect(fakeAuthBloc.capturedEvents, isEmpty);
    });

    testWidgets('invalid email shows error', (tester) async {
      await tester.pumpWidget(buildSignup());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'Client Demo');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'notanemail',
      );

      await scrollAndTap(tester, find.text("S'inscrire"));
      await tester.pumpAndSettle();

      expect(find.text('Email invalide'), findsOneWidget);
      expect(fakeAuthBloc.capturedEvents, isEmpty);
    });

    testWidgets('weak password shows error', (tester) async {
      await tester.pumpWidget(buildSignup());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'Client Demo');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'valid@email.com',
      );
      await tester.enterText(find.byType(TextFormField).at(2), '0700000001');
      await tester.enterText(find.byType(TextFormField).at(3), '123');

      await scrollAndTap(tester, find.text("S'inscrire"));
      await tester.pumpAndSettle();

      expect(find.textContaining('au moins'), findsOneWidget);
      expect(fakeAuthBloc.capturedEvents, isEmpty);
    });
  });

  group('SignupScreen — valid submission', () {
    testWidgets('valid form fires SignUpRequested event', (tester) async {
      await tester.pumpWidget(buildSignup());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'Client Demo');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'demo@boucherie-express.com',
      );
      await tester.enterText(find.byType(TextFormField).at(2), '0700000001');
      await tester.enterText(find.byType(TextFormField).at(3), 'Demo2026!');

      await scrollAndTap(tester, find.text("S'inscrire"));
      await tester.pumpAndSettle();

      expect(fakeAuthBloc.capturedEvents, hasLength(1));
      expect(fakeAuthBloc.capturedEvents.first, isA<SignUpRequested>());
      final event = fakeAuthBloc.capturedEvents.first as SignUpRequested;
      expect(event.email, 'demo@boucherie-express.com');
      expect(event.name, 'Client Demo');
    });

    testWidgets('AuthLoading shows spinner', (tester) async {
      await tester.pumpWidget(buildSignup());
      await tester.pump();

      fakeAuthBloc.fakeEmit(AuthLoading());
      await tester.pump();
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Authenticated navigates to /home', (tester) async {
      await tester.pumpWidget(buildSignup());
      await tester.pump();

      fakeAuthBloc.fakeEmit(Authenticated(tUser));
      await tester.pumpAndSettle();

      expect(router.routerDelegate.currentConfiguration.uri.path, '/home');
    });

    testWidgets('AuthError shows snackbar', (tester) async {
      await tester.pumpWidget(buildSignup());
      await tester.pump();

      fakeAuthBloc.fakeEmit(const AuthError('Email déjà utilisé'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Email déjà utilisé'), findsOneWidget);
    });
  });

  group('SignupScreen — navigation', () {
    testWidgets('"Connectez-vous" navigates to /login', (tester) async {
      await tester.pumpWidget(buildSignup());
      await tester.pumpAndSettle();

      await scrollAndTap(tester, find.text('Connectez-vous'));
      await tester.pumpAndSettle();

      expect(router.routerDelegate.currentConfiguration.uri.path, '/login');
    });
  });
}
