import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:marcador_tenis/models/tournament_model.dart';
import 'package:marcador_tenis/models/tournament_response_model.dart';

class TournamentService {
  final String _url = 'https://backendtorneostenis.onrender.com/api/v1/torneos';

  Future<List<Tournament>> getTournaments() async {
    final start = DateTime.now();
    print('getTournaments INICIO: $start');
    List<Tournament> tournaments = [];
    Uri uri = Uri.parse(_url);
    Response res = await get(uri);

    if (res.statusCode != 200) {
      return tournaments;
    }

    final tournamentResponse = tournamentResponseFromJson(res.body);
    tournaments = tournamentResponse.tournaments;

    final end = DateTime.now();
    print(
      'getTournaments FIN: $end, duracion: ${end.difference(start).inMilliseconds} ms',
    );
    return tournaments;
  }

  Future<bool> postResultadoPartido({
    required String nombreTorneo,
    required String ronda,
    required String jugador1,
    required String jugador2,
    required String resultado,
  }) async {
    final uri = Uri.parse(_url);

    final body = {
      "nombreTorneo": nombreTorneo,
      "ronda": ronda,
      "jugador1": jugador1,
      "jugador2": jugador2,
      "resultado": resultado,
    };

    try {
      final res = await post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
        //Si tarda más de 10 segundos es porque hubo algún error
      ).timeout(const Duration(seconds: 10));

      return res.statusCode == 200 || res.statusCode == 201;
    } catch (e) {
      debugPrint('Error enviando resultado: $e');
      return false;
    }
  }
}
