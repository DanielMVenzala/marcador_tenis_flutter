// To parse this JSON data, do
//
//     final tournamentResponse = tournamentResponseFromJson(jsonString);

import 'dart:convert';

import 'tournament_model.dart';

TournamentResponse tournamentResponseFromJson(String str) =>
    TournamentResponse.fromJson(json.decode(str));

String tournamentResponseToJson(TournamentResponse data) =>
    json.encode(data.toJson());

class TournamentResponse {
  String status;
  List<Tournament> tournaments;

  TournamentResponse({required this.status, required this.tournaments});

  factory TournamentResponse.fromJson(Map<String, dynamic> json) =>
      TournamentResponse(
        status: json["status"],
        tournaments: List<Tournament>.from(
          json["data"].map((x) => Tournament.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": List<dynamic>.from(tournaments.map((x) => x.toJson())),
  };
}
