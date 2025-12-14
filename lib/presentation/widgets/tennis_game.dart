import 'dart:math' as math show Random;

enum PlayerSide { p1, p2 }

class TennisGame {
  int currentSet = 0;
  int pointsP1 = 0;
  int pointsP2 = 0;

  //Lista de juegos de cada set
  List<int> gamesP1 = [0, 0, 0];
  List<int> gamesP2 = [0, 0, 0];

  //Sets ganados por cada jugador
  int setsP1 = 0;
  int setsP2 = 0;

  //Puntos del tiebreak
  int tieBreakP1 = 0;
  int tieBreakP2 = 0;

  //Puntos en los supuestos tiebreak para pintarlos en pequeño
  final List<int?> tieBreakFinalP1 = [null, null, null];
  final List<int?> tieBreakFinalP2 = [null, null, null];
  bool inTieBreak = false;

  //¿Quién saca?
  PlayerSide server = math.Random().nextInt(2) == 0
      ? PlayerSide.p1
      : PlayerSide.p2;

  //Quién empezó sacando el tiebreak actual (si lo hay).
  PlayerSide? tieBreakFirstServer;

  //Quién está sacando ahora mismo (para pintar el triángulo).
  PlayerSide get currentServer {
    if (!inTieBreak) return server;

    // En tie-break usamos el patrón: 1 punto el que empieza, luego bloques de 2.
    if (tieBreakFirstServer == null) return server;

    final first = tieBreakFirstServer!;
    final second = first == PlayerSide.p1 ? PlayerSide.p2 : PlayerSide.p1;

    final totalPoints = tieBreakP1 + tieBreakP2;

    if (totalPoints == 0) {
      // Primer punto del tie-break
      return first;
    } else {
      // A partir del segundo punto:
      // puntos jugados: 1,2,3,4,5,6,...
      // grupos de 2:   [2,3] [4,5] [6,7]...
      final group = (totalPoints - 1) ~/ 2; // 0,0,1,1,2,2,...
      // Grupos pares: saca el segundo, impares: saca el primero
      return (group % 2 == 0) ? second : first;
    }
  }

  void pointTo(PlayerSide side) {
    //Si estamos en el tiebreak se aplica la logica del tiebreak, sino la lógica normal
    inTieBreak ? _pointTieBreak(side) : _pointNormal(side);
  }

  void _pointNormal(PlayerSide side) {
    side == PlayerSide.p1 ? pointsP1++ : pointsP2++;

    //Condicionales para saber si sumamos juego o no
    //Si alguno de los 2 jugadores ha llegado a 40
    if (pointsP1 >= 4 || pointsP2 >= 4) {
      //Y si hay diferencia de 2 puntos (se usa abs para comprobar si sale negativo (J2))
      if ((pointsP1 - pointsP2).abs() >= 2) {
        //Aquí ya se comprueba quien tiene más puntos de los 2 y se le da el juego a quien corresponda
        if (pointsP1 > pointsP2) {
          _winGame(PlayerSide.p1);
        } else {
          _winGame(PlayerSide.p2);
        }
      }
    }
  }

  void _pointTieBreak(PlayerSide side) {
    if (side == PlayerSide.p1) {
      tieBreakP1++;
    } else {
      tieBreakP2++;
    }

    // ganar tie-break: mínimo 7 y diferencia 2
    if ((tieBreakP1 >= 7 || tieBreakP2 >= 7) &&
        (tieBreakP1 - tieBreakP2).abs() >= 2) {
      // asignamos 7-6 en los juegos del set actual
      if (tieBreakP1 > tieBreakP2) {
        gamesP1[currentSet] = 7;
        gamesP2[currentSet] = 6;

        tieBreakFinalP1[currentSet] = tieBreakP1;
        tieBreakFinalP2[currentSet] = tieBreakP2;
        _winSet(PlayerSide.p1);
      } else {
        gamesP2[currentSet] = 7;
        gamesP1[currentSet] = 6;

        tieBreakFinalP1[currentSet] = tieBreakP1;
        tieBreakFinalP2[currentSet] = tieBreakP2;
        _winSet(PlayerSide.p2);
      }

      // al acabar el tie-break, en el siguiente set saca
      // el que no empezó el tie-break
      if (tieBreakFirstServer != null) {
        server = (tieBreakFirstServer == PlayerSide.p1)
            ? PlayerSide.p2
            : PlayerSide.p1;
      }

      // reset del tie-break (ya no estamos en tie-break)
      inTieBreak = false;
      tieBreakP1 = 0;
      tieBreakP2 = 0;
      tieBreakFirstServer = null;
    }
  }

  void _winGame(PlayerSide side) {
    side == PlayerSide.p1 ? gamesP1[currentSet]++ : gamesP2[currentSet]++;

    //Se reinician los puntos
    pointsP1 = 0;
    pointsP2 = 0;

    // Cambiamos el sacador
    server = server == PlayerSide.p1 ? PlayerSide.p2 : PlayerSide.p1;

    // ¿Entramos en tie-break?
    if (gamesP1[currentSet] == 6 && gamesP2[currentSet] == 6) {
      inTieBreak = true;
      tieBreakFirstServer = server;
      return;
    }

    if ((gamesP1[currentSet] >= 6 || gamesP2[currentSet] >= 6) &&
        (gamesP1[currentSet] - gamesP2[currentSet]).abs() >= 2) {
      _winSet(side);
    }
  }

  void _winSet(PlayerSide side) {
    if (currentSet < gamesP1.length - 1) {
      currentSet++;
    }

    inTieBreak = false;
    tieBreakP1 = 0;
    tieBreakP2 = 0;
    pointsP1 = 0;
    pointsP2 = 0;
  }

  String get displayPointsP1 => getPointText(PlayerSide.p1);
  String get displayPointsP2 => getPointText(PlayerSide.p2);

  String getPointText(PlayerSide side) {
    // Si estamos en tie-break, mostramos los puntos numéricos del tie-break
    if (inTieBreak) {
      return side == PlayerSide.p1
          ? tieBreakP1.toString()
          : tieBreakP2.toString();
    }

    // Si no, devolvemos 0/15/30/40/AD
    final pl1 = (side == PlayerSide.p1) ? pointsP1 : pointsP2;
    final pl2 = (side == PlayerSide.p1) ? pointsP2 : pointsP1;

    if (pl1 >= 3 && pl2 >= 3) {
      if (pl1 == pl2) return '40';
      if (pl1 > pl2) return 'AD';
      return '40';
    }

    switch (pl1) {
      case 0:
        return '0';
      case 1:
        return '15';
      case 2:
        return '30';
      case 3:
        return '40';
      default:
        return pl1.toString();
    }
  }
}
