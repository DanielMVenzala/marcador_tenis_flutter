// To parse this JSON data, do
//
//     final playersResponse = playersResponseFromJson(jsonString);

import 'dart:convert';

import 'player_model.dart';

PlayersResponse playersResponseFromJson(String str) =>
    PlayersResponse.fromJson(json.decode(str));

String playersResponseToJson(PlayersResponse data) =>
    json.encode(data.toJson());

class PlayersResponse {
  String status;
  List<Player> players;

  PlayersResponse({required this.status, required this.players});

  factory PlayersResponse.fromJson(Map<String, dynamic> json) =>
      PlayersResponse(
        status: json["status"],
        players: List<Player>.from(json["data"].map((x) => Player.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": List<dynamic>.from(players.map((x) => x.toJson())),
  };
}
