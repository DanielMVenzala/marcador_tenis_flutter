import 'package:just_audio/just_audio.dart';
import 'package:flutter/material.dart';
import 'package:marcador_tenis/models/player_model.dart';
import 'package:marcador_tenis/models/tournament_model.dart';
import 'package:marcador_tenis/services/player_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../widgets/elevated_button_widget.dart';

class PlayerSelectionPage extends StatefulWidget {
  final Tournament tournament;
  final String round;
  const PlayerSelectionPage({
    super.key,
    required this.tournament,
    required this.round,
  });

  @override
  State<PlayerSelectionPage> createState() => _PlayerSelectionPageState();
}

class _PlayerSelectionPageState extends State<PlayerSelectionPage> {
  //Lista de jugadores seleccionados
  List<int> selectedPlayersIndex = [];

  late Future<List<Player>> _playersFuture;
  final PlayerService playerService = PlayerService();
  late final AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _playersFuture = playerService.getPlayers();
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose(); //  importante para liberar recursos
    super.dispose();
  }

  Future<void> _playPlayerAudio(Player player) async {
    try {
      await _audioPlayer.stop();

      final assetPath = 'assets/audio/${player.audioRef}';

      await _audioPlayer.setAsset(assetPath);
      await _audioPlayer.play();
    } catch (e) {
      print('Error reproduciendo audio: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08145c),
      body: FutureBuilder(
        future: _playersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final players = snapshot.data ?? [];

          List<Player> selectedPlayers = [];

          // Solo llenamos la lista cuando hay 2 seleccionados
          if (selectedPlayersIndex.length >= 2) {
            selectedPlayers = [
              players[selectedPlayersIndex[0]],
              players[selectedPlayersIndex[1]],
            ];
          }

          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Column(
                  children: [
                    Text(
                      'Selección de jugadores:',
                      style: const TextStyle(
                        fontSize: 40,
                        color: Colors.white,
                        fontFamily: 'Bebas',
                      ),
                      textAlign: TextAlign.center,
                    ),

                    Expanded(
                      child: Center(
                        child: FractionallySizedBox(
                          widthFactor: 0.95,
                          heightFactor: 0.90,
                          child: GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 5,
                                  crossAxisSpacing: 32,
                                  mainAxisSpacing: 32,
                                ),
                            itemCount: players.length,
                            itemBuilder: (context, index) {
                              final player = players[index];
                              final isSelected = selectedPlayersIndex.contains(
                                index,
                              );
                              return _PlayerCard(
                                isSelected: isSelected,
                                player: player,
                                onTap: () {
                                  setState(() {
                                    if (isSelected) {
                                      selectedPlayersIndex.remove(index);
                                    } else {
                                      if (selectedPlayersIndex.length < 2) {
                                        selectedPlayersIndex.add(index);
                                        _playPlayerAudio(player);
                                      }
                                    }
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          child: ElevatedButtonWidget(
                            enabled: selectedPlayersIndex.isNotEmpty,
                            text: 'Cancelar',
                            onPressedCustom: () {
                              setState(() {
                                selectedPlayersIndex.clear();
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 40),
                        SizedBox(
                          child: ElevatedButtonWidget(
                            enabled: selectedPlayersIndex.length == 2,
                            route: '/game',
                            text: 'Comenzar partido',
                            players: selectedPlayers,
                            tournament: widget.tournament,
                            round: widget.round,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),

              Positioned(
                top: 40,
                left: 30,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    size: 35,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PlayerCard extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final Player player;

  const _PlayerCard({
    required this.player,
    required this.onTap,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    String completeName = '${player.nombre} ${player.apellidos}';
    return Card(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected
                      ? const Color.fromARGB(255, 40, 230, 40).withOpacity(0.6)
                      : Colors.transparent,
                  width: 4,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: SizedBox(
                  width: 230,
                  height: 230,
                  child: Image.network(
                    player.foto,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.person, size: 40, color: Colors.white),
                  ),
                ),
              ),
            ),

            Positioned(
              left: 0,
              child: RotatedBox(
                quarterTurns: 3,
                child: Text(
                  completeName,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.15),
                    fontSize: completeName.length >= 17 ? 23 : 27,
                    fontFamily: 'Bebas',
                  ),
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: player.ranking != 0
                    ? Text(
                        '#${player.ranking}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.15),
                          fontSize: 50,
                          fontFamily: 'Bebas',
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.only(left: 6, top: 8.0),
                        child: FaIcon(
                          FontAwesomeIcons.crown,
                          size: 50,
                          color: Colors.white.withOpacity(0.10),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
