import 'package:go_router/go_router.dart';
import 'package:marcador_tenis/presentation/screens/game_page.dart';
import 'package:marcador_tenis/presentation/screens/home_page.dart';
import 'package:marcador_tenis/presentation/screens/player_selection_page.dart';
import 'package:marcador_tenis/presentation/screens/round_selection_page.dart';
import 'package:marcador_tenis/presentation/screens/tournament_selection_page.dart';

import '../models/player_model.dart';
import '../models/tournament_model.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/tournamentSelection',
      builder: (context, state) {
        return TournamentSelectionPage();
      },
    ),
    GoRoute(
      path: '/roundSelection',
      builder: (context, state) {
        final extras = state.extra as Map<String, dynamic>?;
        final tournament = extras?['tournament'] as Tournament?;
        return RoundSelectionPage(tournament: tournament!);
      },
    ),
    GoRoute(
      path: '/playersSelection',
      builder: (context, state) {
        final extras = state.extra as Map<String, dynamic>?;
        final tournament = extras?['tournament'] as Tournament?;
        final round = extras?['round'] as String?;
        return PlayerSelectionPage(tournament: tournament!, round: round!);
      },
    ),

    GoRoute(
      path: '/game',
      builder: (context, state) {
        final extras = state.extra as Map<String, dynamic>?;
        final tournament = extras?['tournament'] as Tournament?;
        final round = extras?['round'] as String?;
        final players = extras?['players'] as List<Player>?;

        return GamePage(
          tournament: tournament!,
          round: round!,
          players: players!,
        );
      },
    ),
  ],
);
