import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/features/auth/screens/login_screen.dart';
import 'package:myapp/features/game/screens/game_screen.dart';
import 'package:myapp/features/home/screens/home_screen.dart';
import 'package:myapp/features/lobby/screens/lobby_screen.dart';
import 'package:myapp/features/lobby/screens/waiting_room_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/login',
  routes: <RouteBase>[
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) {
        return const LoginScreen();
      },
    ),
    GoRoute(
      path: '/home',
      builder: (BuildContext context, GoRouterState state) {
        return const HomeScreen();
      },
    ),
    GoRoute(
      path: '/lobby',
      builder: (BuildContext context, GoRouterState state) {
        return const LobbyScreen();
      },
    ),
    GoRoute(
      path: '/lobby/waiting/:roomId',
      builder: (BuildContext context, GoRouterState state) {
        final roomId = state.pathParameters['roomId']!;
        return WaitingRoomScreen(roomId: roomId);
      },
    ),
    GoRoute(
      path: '/game/:roomId',
      builder: (BuildContext context, GoRouterState state) {
        final roomId = state.pathParameters['roomId']!;
        return GameScreen(roomId: roomId);
      },
    ),
  ],
);
