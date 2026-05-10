import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:boucherie_express/features/auth/domain/entities/user.dart';
import 'package:boucherie_express/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:boucherie_express/features/auth/presentation/bloc/phone_auth_bloc.dart';

// ── Fixture ────────────────────────────────────────────────────────────────

final tUser = User(
  id: 'test-uid-001',
  email: 'demo@boucherie-express.com',
  name: 'Client Demo',
  phone: '0700000001',
  createdAt: DateTime(2026, 1, 1),
);

// ── FakeAuthBloc ───────────────────────────────────────────────────────────
// AuthBloc has injected use-case fields that can't be constructed in tests.
// Use Fake (noSuchMethod stubs) + StreamController to satisfy the interface.

class FakeAuthBloc extends Fake implements AuthBloc {
  final _ctrl = StreamController<AuthState>.broadcast(sync: true);
  AuthState _state = AuthInitial();
  final capturedEvents = <AuthEvent>[];

  @override
  AuthState get state => _state;

  @override
  Stream<AuthState> get stream => _ctrl.stream;

  @override
  bool get isClosed => _ctrl.isClosed;

  @override
  void add(AuthEvent event) => capturedEvents.add(event);

  void fakeEmit(AuthState s) {
    _state = s;
    _ctrl.add(s);
  }

  @override
  Future<void> close() async {
    if (!_ctrl.isClosed) await _ctrl.close();
  }
}

// ── FakePhoneAuthBloc ──────────────────────────────────────────────────────
// PhoneAuthEvent/PhoneAuthState are sealed — cannot extend outside their
// library. Use a StreamController-backed Fake instead.

class FakePhoneAuthBloc extends Fake implements PhoneAuthBloc {
  final _ctrl = StreamController<PhoneAuthState>.broadcast(sync: true);
  PhoneAuthState _state = PhoneAuthInitial();
  final capturedEvents = <PhoneAuthEvent>[];

  @override
  PhoneAuthState get state => _state;

  @override
  Stream<PhoneAuthState> get stream => _ctrl.stream;

  @override
  bool get isClosed => _ctrl.isClosed;

  @override
  void add(PhoneAuthEvent event) => capturedEvents.add(event);

  void fakeEmit(PhoneAuthState s) {
    _state = s;
    _ctrl.add(s);
  }

  @override
  Future<void> close() async {
    if (!_ctrl.isClosed) await _ctrl.close();
  }
}

// ── Test app builder ───────────────────────────────────────────────────────

/// Wraps screen in a `BlocProvider&lt;AuthBloc&gt;` + MaterialApp.router.
Widget buildAuthTestApp({
  required Widget screen,
  required GoRouter router,
  FakeAuthBloc? authBloc,
}) {
  return BlocProvider<AuthBloc>.value(
    value: authBloc ?? FakeAuthBloc(),
    child: MaterialApp.router(routerConfig: router),
  );
}
