import 'package:http/http.dart';
import 'package:marcador_tenis/models/player_response_model.dart';
import '../models/player_model.dart';

class PlayerService {
  final String _url =
      'https://backendjugadorestenis.onrender.com/api/v1/jugadores';

  Future<List<Player>> getPlayers() async {
    //Para comprobar el tiempo de la respuesta
    final start = DateTime.now();
    print('getPlayers INICIO: $start');
    List<Player> players = [];
    Uri uri = Uri.parse(_url);

    Response res = await get(uri);

    if (res.statusCode != 200) {
      return players;
    }

    final playersResponse = playersResponseFromJson(res.body);
    players = playersResponse.players;

    final end = DateTime.now();
    print(
      'getPlayers FIN: $end, duracion: ${end.difference(start).inMilliseconds} ms',
    );
    return players;
  }
}
