import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:boucherie_express/features/auth/presentation/bloc/phone_auth_bloc.dart';
import 'package:boucherie_express/features/auth/presentation/screens/otp_verification_screen.dart';
import 'package:boucherie_express/features/auth/presentation/widgets/resend_timer.dart';

import '../../helpers/auth_mocks.dart';

void main() {
  late FakePhoneAuthBloc fakePhoneBloc;
  late GoRouter router;

  const testPhone = '0700000001';
  const testFormattedPhone = '+225 07 00 00 00 01';

  // OtpVerificationScreen creates its own BlocProvider via phoneAuthBloc param.
  Widget buildOtpScreen() => MaterialApp.router(routerConfig: router);

  setUp(() {
    fakePhoneBloc = FakePhoneAuthBloc();

    router = GoRouter(
      initialLocation: '/otp-verification',
      routes: [
        GoRoute(
          path: '/otp-verification',
          builder: (_, __) => OtpVerificationScreen(
            phone: testPhone,
            formattedPhone: testFormattedPhone,
            phoneAuthBloc: fakePhoneBloc,
          ),
        ),
        GoRoute(path: '/home', builder: (_, __) => const Scaffold()),
        GoRoute(path: '/login', builder: (_, __) => const Scaffold()),
      ],
    );
  });

  tearDown(() async {
    await fakePhoneBloc.close();
    router.dispose();
  });

  /// Pump enough to settle the initial layout without looping on the timer.
  Future<void> buildAndSettle(WidgetTester tester) async {
    await tester.pumpWidget(buildOtpScreen());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  group('OtpVerificationScreen — display', () {
    testWidgets('shows formatted phone number', (tester) async {
      await buildAndSettle(tester);
      expect(find.textContaining(testFormattedPhone), findsOneWidget);
    });

    testWidgets('ResendTimer widget is visible', (tester) async {
      await buildAndSettle(tester);
      expect(find.byType(ResendTimer), findsOneWidget);
    });
  });

  group('OtpVerificationScreen — state handling', () {
    testWidgets('OtpVerifiedSuccess navigates to /home', (tester) async {
      await buildAndSettle(tester);

      fakePhoneBloc.fakeEmit(OtpVerifiedSuccess(user: tUser));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(router.routerDelegate.currentConfiguration.uri.path, '/home');
    });

    testWidgets('PhoneAuthError shows snackbar', (tester) async {
      await buildAndSettle(tester);

      fakePhoneBloc.fakeEmit(const PhoneAuthError(message: 'Code invalide'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Code invalide'), findsOneWidget);
    });

    testWidgets('OtpResent shows success snackbar', (tester) async {
      await buildAndSettle(tester);

      fakePhoneBloc.fakeEmit(
        const OtpResent(
          phone: testPhone,
          formattedPhone: testFormattedPhone,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Code renvoyé avec succès'), findsOneWidget);
    });
  });

  group('OtpVerificationScreen — OTP input', () {
    testWidgets('verify button is present', (tester) async {
      await buildAndSettle(tester);
      expect(find.widgetWithText(ElevatedButton, 'VÉRIFIER'), findsOneWidget);
    });
  });
}
