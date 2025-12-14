import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marcador_tenis/presentation/screens/tournament_selection_page.dart';
import 'package:marcador_tenis/services/tournament_service.dart';

import '../../models/player_model.dart';
import '../../models/tournament_model.dart';
import '../widgets/tennis_game.dart';

class GamePage extends StatefulWidget {
  final List<Player> players;
  final Tournament tournament;
  String round;
  GamePage({
    super.key,
    required this.players,
    required this.tournament,
    required this.round,
  });

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late DateTime startTime;
  late Player player1;
  late Player player2;
  late TennisGame game;
  bool _matchEndDialog = false;

  @override
  void initState() {
    super.initState();
    player1 = widget.players[0];
    player2 = widget.players[1];
    startTime = DateTime.now();
    game = TennisGame();
  }

  bool get _isMatchFinished {
    int setsWonP1 = 0;
    int setsWonP2 = 0;

    for (int i = 0; i < 3; i++) {
      final g1 = game.gamesP1[i];
      final g2 = game.gamesP2[i];

      final maxGames = g1 > g2 ? g1 : g2;
      final diff = (g1 - g2).abs();

      // Set terminado
      final finished = (maxGames >= 6 && diff >= 2) || maxGames == 7;

      if (!finished) continue;

      if (g1 > g2) {
        setsWonP1++;
      } else {
        setsWonP2++;
      }
    }

    return setsWonP1 == 2 || setsWonP2 == 2;
  }

  String _getScoreString() {
    final scores = <String>[];

    for (int i = 0; i < 3; i++) {
      final g1 = game.gamesP1[i];
      final g2 = game.gamesP2[i];

      final maxGames = g1 > g2 ? g1 : g2;
      final minGames = g1 < g2 ? g1 : g2;
      final diff = (g1 - g2).abs();

      // Set terminado según puntuación típica de tenis:
      // - 6 o más juegos y diferencia de 2
      // - o alguien llega a 7 (tie-break ganado)
      final finished = (maxGames >= 6 && diff >= 2) || maxGames == 7;
      if (!finished) continue;

      // Sólo hay tie-break si el ganador tiene 7 y el perdedor 6
      final isTieBreak = maxGames == 7 && minGames == 6;

      if (!isTieBreak) {
        // Set normal (ej. 6-3, 7-5)
        scores.add('$g1-$g2');
      } else {
        // Set con tie-break -> 7-6(X) o 6-7(X)
        if (g1 > g2) {
          final loserTB = game.tieBreakFinalP2[i];
          if (loserTB != null) {
            scores.add('$g1-$g2($loserTB)');
          } else {
            scores.add('$g1-$g2');
          }
        } else {
          final loserTB = game.tieBreakFinalP1[i];
          if (loserTB != null) {
            scores.add('$g1-$g2($loserTB)');
          } else {
            scores.add('$g1-$g2');
          }
        }
      }
    }

    return scores.join(', ');
  }

  void _onPoint(PlayerSide side) {
    if (_isMatchFinished) return;

    setState(() {
      game.pointTo(side);
    });

    if (_isMatchFinished && !_matchEndDialog) {
      _matchEndDialog = true;
      _showMatchEndDialog();
    }
  }

  Future<void> _showMatchEndDialog() async {
    final TournamentService tournamentService = TournamentService();
    int setsWonP1 = 0;
    int setsWonP2 = 0;

    for (int i = 0; i < 3; i++) {
      final g1 = game.gamesP1[i];
      final g2 = game.gamesP2[i];

      final maxGames = g1 > g2 ? g1 : g2;
      final diff = (g1 - g2).abs();

      final finished = (maxGames >= 6 && diff >= 2) || maxGames == 7;
      if (!finished) continue;

      if (g1 > g2) {
        setsWonP1++;
      } else {
        setsWonP2++;
      }
    }

    final winner = setsWonP1 > setsWonP2 ? player1 : player2;
    final loser = setsWonP1 > setsWonP2 ? player2 : player1;
    final score = _getScoreString();

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 35, 35, 35),
          title: const Text(
            'Fin del partido',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            '${winner.nombre} ${winner.apellidos} ha ganado a '
            '${loser.nombre} ${loser.apellidos} por: $score.\n\n'
            '¿Quieres subir el resultado a la base de datos?',
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar', style: TextStyle(fontSize: 20)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Aceptar', style: TextStyle(fontSize: 20)),
            ),
          ],
        );
      },
    );

    if (result == true) {
      if (widget.round.toLowerCase().startsWith('c'))
        widget.round = 'cuartos_de_final';
      if (widget.round.toLowerCase().startsWith('s'))
        widget.round = 'semifinales';
      if (widget.round.toLowerCase().startsWith('f')) widget.round = 'final';

      final successPost = await tournamentService.postResultadoPartido(
        nombreTorneo: widget.tournament.nombre,
        ronda: widget.round,
        jugador1: widget.players[0].apellidos,
        jugador2: widget.players[1].apellidos,
        resultado: score,
      );

      if (successPost) {
        //Mounted sigue para comprobar si el widget sigue en pantalla o no
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Resultado subido correctamente')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No hay más espacios en esta ronda')),
          );
        }
      }
    }

    // Después de aceptar o cancelar, navegas a tu otra pantalla
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const TournamentSelectionPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isTieBreakSet(int g1, int g2) {
      return (g1 == 7 && g2 == 6) || (g2 == 7 && g1 == 6);
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 35, 35, 35),
      body: Column(
        children: [
          SizedBox(height: 45),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StreamBuilder(
                stream: Stream.periodic(Duration(seconds: 1)),
                builder: (_, __) {
                  final n = DateTime.now();
                  return Text(
                    "${n.hour.toString().padLeft(2, '0')}:${n.minute.toString().padLeft(2, '0')}",
                    style: TextStyle(color: Colors.white, fontSize: 40),
                  );
                },
              ),
              SizedBox(width: 270),
              Image.asset('assets/images/rolex.png', width: 50),
              SizedBox(width: 20),
              Text(
                'ROLEX',
                style: GoogleFonts.ebGaramond(
                  fontSize: 45,
                  color: Color(0xFF9b7a33),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 20),
              Image.asset('assets/images/rolex.png', width: 50),
              SizedBox(width: 270),
              StreamBuilder<int>(
                stream: Stream.periodic(Duration(minutes: 1), (count) => count),
                builder: (context, snapshot) {
                  final diff = DateTime.now().difference(startTime);
                  final totalMinutes = diff.inMinutes;

                  final hours = (totalMinutes ~/ 60).toString().padLeft(2, '0');
                  final minutes = (totalMinutes % 60).toString().padLeft(
                    2,
                    '0',
                  );

                  return Text(
                    "$hours:$minutes",
                    style: TextStyle(color: Colors.white, fontSize: 40),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 30),
          Divider(
            color: const Color.fromARGB(255, 64, 107, 216),
            thickness: 4, // grosor de la línea
            height: 0, // evita espacio extra
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'POINTS',
                style: TextStyle(color: Colors.white, fontSize: 30),
              ),
              SizedBox(width: 150),
              Text('1', style: TextStyle(color: Colors.white, fontSize: 30)),
              SizedBox(width: 100),
              Text('2', style: TextStyle(color: Colors.white, fontSize: 30)),
              SizedBox(width: 100),
              Text('3', style: TextStyle(color: Colors.white, fontSize: 30)),
              SizedBox(width: 50),
            ],
          ),
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(width: 10),

              // Triángulo si saca el jugador 1
              if (game.currentServer == PlayerSide.p1)
                const Icon(Icons.play_arrow, color: Colors.yellow, size: 24)
              else
                const SizedBox(width: 24),

              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${player1.nombre}\n${player1.apellidos} (${player1.pais})',
                  style: TextStyle(color: Colors.white, fontSize: 35),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 64, 107, 216),
                ),
                child: Text(
                  game.getPointText(PlayerSide.p1),
                  style: TextStyle(color: Colors.white, fontSize: 50),
                ),
              ),
              SizedBox(width: 145),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Stack(
                  children: [
                    Text(
                      game.gamesP1[0].toString(),
                      style: TextStyle(color: Colors.white, fontSize: 50),
                    ),

                    // Si tie-break en curso en este set -> mostrar tieP1
                    if (isTieBreakSet(game.gamesP1[0], game.gamesP2[0]))
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Text(
                          game.tieBreakFinalP1[0] != null
                              ? game.tieBreakFinalP1[0].toString()
                              : '',
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ),
                  ],
                ),
              ),

              SizedBox(width: 49),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Stack(
                  children: [
                    Text(
                      game.gamesP1[1].toString(),
                      style: TextStyle(color: Colors.white, fontSize: 50),
                    ),
                    // Si tie-break en curso en este set -> mostrar tieP1
                    if (isTieBreakSet(game.gamesP1[1], game.gamesP2[1]))
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Text(
                          game.tieBreakFinalP1[1] != null
                              ? game.tieBreakFinalP1[1].toString()
                              : '',
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ),
                  ],
                ),
              ),

              SizedBox(width: 48),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Stack(
                  children: [
                    Text(
                      game.gamesP1[2].toString(),
                      style: TextStyle(color: Colors.white, fontSize: 50),
                    ),
                    // Si tie-break en curso en este set -> mostrar tieP1
                    if (isTieBreakSet(game.gamesP1[2], game.gamesP2[2]))
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Text(
                          game.tieBreakFinalP1[2] != null
                              ? game.tieBreakFinalP1[2].toString()
                              : '',
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ),
                  ],
                ),
              ),

              SizedBox(width: 25),
            ],
          ),
          SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(width: 10),

              // Triángulo si saca el jugador 1
              if (game.currentServer == PlayerSide.p2)
                const Icon(Icons.play_arrow, color: Colors.yellow, size: 24)
              else
                const SizedBox(width: 24),

              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${player2.nombre}\n${player2.apellidos} (${player2.pais})',
                  style: TextStyle(color: Colors.white, fontSize: 35),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 64, 107, 216),
                ),
                child: Text(
                  game.getPointText(PlayerSide.p2),
                  style: TextStyle(color: Colors.white, fontSize: 50),
                ),
              ),
              SizedBox(width: 145),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                child: Stack(
                  children: [
                    Text(
                      game.gamesP2[0].toString(),
                      style: TextStyle(color: Colors.white, fontSize: 50),
                    ),
                    // Si tie-break en curso en este set -> mostrar tieP1
                    if (isTieBreakSet(game.gamesP2[0], game.gamesP1[0]))
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Text(
                          game.tieBreakFinalP2[0] != null
                              ? game.tieBreakFinalP2[0].toString()
                              : '',
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ),
                  ],
                ),
              ),

              SizedBox(width: 49),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Stack(
                  children: [
                    Text(
                      game.gamesP2[1].toString(),
                      style: TextStyle(color: Colors.white, fontSize: 50),
                    ),
                    // Si tie-break en curso en este set -> mostrar tieP1
                    if (isTieBreakSet(game.gamesP2[1], game.gamesP1[1]))
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Text(
                          game.tieBreakFinalP2[1] != null
                              ? game.tieBreakFinalP2[1].toString()
                              : '',
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(width: 48),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Stack(
                  children: [
                    Text(
                      game.gamesP2[2].toString(),
                      style: TextStyle(color: Colors.white, fontSize: 50),
                    ),
                    // Si tie-break en curso en este set -> mostrar tieP1
                    if (isTieBreakSet(game.gamesP2[2], game.gamesP1[2]))
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Text(
                          game.tieBreakFinalP2[2] != null
                              ? game.tieBreakFinalP2[2].toString()
                              : '',
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(width: 25),
            ],
          ),

          SizedBox(height: 50),
          Divider(
            color: const Color.fromARGB(255, 64, 107, 216),
            thickness: 4, // grosor de la línea
            height: 0, // evita espacio extra
          ),
          SizedBox(height: 30),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                child: _ElevatedButtomPoints(
                  lastName: player1.apellidos,
                  onPressedCustom: _isMatchFinished
                      ? null
                      : () => _onPoint(PlayerSide.p1),
                ),
              ),
              SizedBox(width: 40),
              SizedBox(
                child: _ElevatedButtomPoints(
                  lastName: player2.apellidos,
                  onPressedCustom: _isMatchFinished
                      ? null
                      : () => _onPoint(PlayerSide.p2),
                ),
              ),
            ],
          ),

          SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _ElevatedButtomPoints extends StatefulWidget {
  final String? lastName;
  final VoidCallback? onPressedCustom;
  const _ElevatedButtomPoints({required this.lastName, this.onPressedCustom});

  @override
  State<_ElevatedButtomPoints> createState() => __ElevatedButtomPointsState();
}

class __ElevatedButtomPointsState extends State<_ElevatedButtomPoints> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color.fromARGB(255, 64, 107, 216),
        //Foregroundcolor define el color del contenido del botón
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      onPressed: widget.onPressedCustom,
      child: Text(
        'Punto para ${widget.lastName}',
        style: TextStyle(
          fontSize: 25,
          fontFamily: 'Bebas',
          color: Colors.white,
        ),
      ),
    );
  }
}
