import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:marcador_tenis/models/tournament_model.dart';

import '../widgets/elevated_button_widget.dart';

class RoundSelectionPage extends StatefulWidget {
  final Tournament tournament;
  const RoundSelectionPage({super.key, required this.tournament});

  @override
  State<RoundSelectionPage> createState() => _RoundSelectionPageState();
}

class _RoundSelectionPageState extends State<RoundSelectionPage> {
  String? selectedRound;

  Widget _roundButton(String text) {
    final bool isSelected = selectedRound == text;

    return SizedBox(
      width: 280,
      height: 80,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected
              ? const Color(0xFF406BD8)
              : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: () {
          setState(() {
            selectedRound = text;
          });
        },
        child: Text(
          text.toUpperCase(),
          style: const TextStyle(
            fontFamily: 'Bebas',
            fontSize: 25,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08145c),
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Selecciona la ronda:',
                    style: TextStyle(
                      fontFamily: 'Bebas',
                      color: Colors.white,
                      fontSize: 45,
                    ),
                  ),
                  const SizedBox(height: 40),

                  _roundButton('Cuartos de final'),
                  const SizedBox(height: 20),

                  _roundButton('Semifinal'),
                  const SizedBox(height: 20),

                  _roundButton('Final'),
                  const SizedBox(height: 40),

                  SizedBox(
                    width: 320,
                    height: 80,
                    child: ElevatedButtonWidget(
                      enabled: selectedRound != null,
                      text: 'Selección de jugadores',
                      onPressedCustom: () {
                        if (selectedRound == null) return;

                        context.push(
                          '/playersSelection',
                          extra: {
                            'tournament': widget.tournament,
                            'round': selectedRound!,
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
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
      ),
    );
  }
}
