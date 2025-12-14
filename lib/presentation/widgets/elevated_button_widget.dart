import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/player_model.dart';
import '../../models/tournament_model.dart';

class ElevatedButtonWidget extends StatefulWidget {
  final bool enabled;
  final String? route;
  final String text;

  // Datos que pueden llegar o no
  final List<Player>? players;
  final Tournament? tournament;
  final String? round;

  // Acción personalizada opcional
  final VoidCallback? onPressedCustom;

  const ElevatedButtonWidget({
    super.key,
    required this.enabled,
    required this.text,
    this.route,
    this.players,
    this.tournament,
    this.round,
    this.onPressedCustom,
  });

  @override
  State<ElevatedButtonWidget> createState() => _ElevatedButtonWidgetState();
}

class _ElevatedButtonWidgetState extends State<ElevatedButtonWidget> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        disabledBackgroundColor: const Color.fromARGB(
          255,
          255,
          255,
          255,
        ).withOpacity(0.4),
        disabledForegroundColor: Colors.black.withOpacity(0.4),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      //Si no está habilitado no hace nada, si lo está ejecuta la función
      onPressed: !widget.enabled
          ? null
          : () {
              // Acción personalizada, si existe
              if (widget.onPressedCustom != null) {
                widget.onPressedCustom!();
                return;
              }

              if (widget.route != null) {
                // Construimos un Map con las claves que existan
                final Map<String, dynamic> extra = {};

                if (widget.tournament != null) {
                  extra['tournament'] = widget.tournament;
                }
                if (widget.players != null) {
                  extra['players'] = widget.players;
                }
                if (widget.round != null) {
                  extra['round'] = widget.round;
                }

                // Si no hay nada que enviar, mandamos null
                final Object? object = extra.isEmpty ? null : extra;

                context.push(widget.route!, extra: object);
              }
            },
      child: Text(
        widget.text,
        style: const TextStyle(fontSize: 25, fontFamily: 'Bebas'),
      ),
    );
  }
}
