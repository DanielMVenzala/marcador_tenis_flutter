import 'package:flutter/material.dart';
import 'package:marcador_tenis/services/tournament_service.dart';
import 'package:marcador_tenis/presentation/widgets/elevated_button_widget.dart';
import '../../models/tournament_model.dart';

class TournamentSelectionPage extends StatefulWidget {
  const TournamentSelectionPage({super.key});

  @override
  State<TournamentSelectionPage> createState() =>
      _TournamentSelectionPageState();
}

class _TournamentSelectionPageState extends State<TournamentSelectionPage> {
  late Future<List<Tournament>> _tournamentsFuture;
  int? selectedTournamentIndex;
  final TournamentService tournamentService = TournamentService();

  @override
  void initState() {
    super.initState();
    _tournamentsFuture = tournamentService.getTournaments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08145c),
      body: FutureBuilder(
        future: _tournamentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final tournaments = snapshot.data ?? [];
          final Tournament? selectedTournament = selectedTournamentIndex != null
              ? tournaments[selectedTournamentIndex!]
              : null;

          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SizedBox(height: 60),
                    Text(
                      'Selecciona el Grand Slam:',
                      style: TextStyle(
                        fontFamily: 'Bebas',
                        color: Colors.white,
                        fontSize: 45,
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          runAlignment: WrapAlignment.center,
                          spacing: 60,
                          runSpacing: 60,
                          children: List.generate(tournaments.length, (index) {
                            final torneo = tournaments[index];
                            return _TournamentLogo(
                              name: torneo.nombre,
                              logoUrl: torneo.logo,
                              isSelected: selectedTournamentIndex == index,
                              onTap: () {
                                setState(() {
                                  selectedTournamentIndex = index;
                                });
                              },
                            );
                          }),
                        ),
                      ),
                    ),

                    SizedBox(
                      child: ElevatedButtonWidget(
                        enabled: selectedTournamentIndex != null,
                        route: '/roundSelection',
                        text: 'Selección de ronda',
                        tournament: selectedTournament,
                      ),
                    ),
                    SizedBox(height: 80),
                  ],
                ),
              ),

              Positioned(
                top: 40,
                left: 30,
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
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

class _TournamentLogo extends StatelessWidget {
  final String name;
  final String logoUrl;
  final bool isSelected;
  final VoidCallback onTap;

  const _TournamentLogo({
    required this.name,
    required this.logoUrl,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
              borderRadius: BorderRadius.circular(20),
            ),
            child: SizedBox(
              width: 160,
              height: 160,
              child: Image.network(logoUrl, fit: BoxFit.contain),
            ),
          ),
        ],
      ),
    );
  }
}
