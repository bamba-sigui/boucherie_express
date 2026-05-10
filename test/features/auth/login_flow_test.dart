import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:boucherie_express/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:boucherie_express/features/auth/presentation/bloc/phone_auth_bloc.dart';
import 'package:boucherie_express/features/auth/presentation/screens/login_screen.dart';

import '../../helpers/auth_mocks.dart';

void main() {
  late FakeAuthBloc fakeAuthBloc;
  late FakePhoneAuthBloc fakePhoneBloc;
  late GoRouter router;

  Widget buildLogin() {
    return BlocProvider<AuthBloc>.value(
      value: fakeAuthBloc,
      child: MaterialApp.router(routerConfig: router),
    );
  }

  setUp(() {
    fakeAuthBloc = FakeAuthBloc();
    fakePhoneBloc = FakePhoneAuthBloc();

    // Inject fakePhoneBloc directly — avoids GetIt
    router = GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(
          path: '/login',
          builder: (_, __) => LoginScreen(phoneAuthBloc: fakePhoneBloc),
        ),
        GoRoute(path: '/signup', builder: (_, __) => const Scaffold()),
        GoRoute(path: '/home', builder: (_, __) => const Scaffold()),
        GoRoute(
          path: '/otp-verification',
          builder: (_, __) => const Scaffold(),
        ),
      ],
    );
  });

  tearDown(() async {
    await fakeAuthBloc.close();
    await fakePhoneBloc.close();
    router.dispose();
  });

  /// Build widget and pump enough to settle initial animations.
  Future<void> buildAndSettle(WidgetTester tester) async {
    await tester.pumpWidget(buildLogin());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  group('LoginScreen — email tab (default)', () {
    testWidgets('email tab shown by default', (tester) async {
      await buildAndSettle(tester);

      expect(find.byType(TextFormField), findsWidgets);
      expect(find.text('E-mail'), findsOneWidget);
    });

    testWidgets('empty form shows validation errors', (tester) async {
      await buildAndSettle(tester);

      await tester.tap(find.text('CONNEXION'));
      await tester.pump();

      expect(find.textContaining('requis'), findsAtLeastNWidgets(1));
      expect(fakeAuthBloc.capturedEvents, isEmpty);
    });

    testWidgets('valid credentials fire CheckEmailAndLogin event', (
      tester,
    ) async {
      await buildAndSettle(tester);

      await tester.enterText(
        find.byType(TextFormField).first,
        'demo@boucherie-express.com',
      );
      await tester.enterText(find.byType(TextFormField).last, 'Demo2026!');

      await tester.tap(find.text('CONNEXION'));
      await tester.pump();
      await tester.pump();

      expect(fakeAuthBloc.capturedEvents, hasLength(1));
      expect(fakeAuthBloc.capturedEvents.first, isA<CheckEmailAndLogin>());
      final event = fakeAuthBloc.capturedEvents.first as CheckEmailAndLogin;
      expect(event.email, 'demo@boucherie-express.com');
    });

    testWidgets('Authenticated state navigates to /home', (tester) async {
      await buildAndSettle(tester);

      fakeAuthBloc.fakeEmit(Authenticated(tUser));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(router.routerDelegate.currentConfiguration.uri.path, '/home');
    });

    testWidgets('EmailNotRegistered state navigates to /signup', (
      tester,
    ) async {
      await buildAndSettle(tester);
      expect(router.canPop(), isFalse);

      fakeAuthBloc.fakeEmit(const EmailNotRegistered('unknown@example.com'));
      await tester.pump();

      // context.push adds an imperative route — canPop becomes true.
      expect(router.canPop(), isTrue);
    });

    testWidgets('AuthError shows snackbar', (tester) async {
      await buildAndSettle(tester);

      fakeAuthBloc.fakeEmit(const AuthError('Identifiants incorrects'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Identifiants incorrects'), findsOneWidget);
    });
  });

  group('LoginScreen — phone tab', () {
    testWidgets('tap Numéro tab shows phone field', (tester) async {
      await buildAndSettle(tester);

      await tester.tap(find.text('Numéro'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Numéro'), findsOneWidget);
    });

    testWidgets('OtpSentSuccess navigates to /otp-verification', (
      tester,
    ) async {
      await buildAndSettle(tester);
      expect(router.canPop(), isFalse);

      fakePhoneBloc.fakeEmit(
        const OtpSentSuccess(
          phone: '0700000001',
          formattedPhone: '+225 07 00 00 00 01',
        ),
      );
      await tester.pump();

      expect(router.canPop(), isTrue);
    });

    testWidgets('PhoneNotRegistered state navigates to /signup', (
      tester,
    ) async {
      await buildAndSettle(tester);
      expect(router.canPop(), isFalse);

      fakePhoneBloc.fakeEmit(
        const PhoneNotRegistered(phone: '0799999999'),
      );
      await tester.pump();

      expect(router.canPop(), isTrue);
    });
  });

  group('LoginScreen — signup link', () {
    testWidgets('"S\'inscrire" link is visible', (tester) async {
      await buildAndSettle(tester);

      expect(find.text("S'inscrire"), findsOneWidget);
    });
  });
}
