class Tournament {
  String id;
  String nombre;
  String logo;
  Ronda ronda;

  Tournament({
    required this.id,
    required this.nombre,
    required this.logo,
    required this.ronda,
  });

  factory Tournament.fromJson(Map<String, dynamic> json) => Tournament(
    id: json["_id"],
    nombre: json["nombre"],
    logo: json["logo"],
    ronda: Ronda.fromJson(json["ronda"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "nombre": nombre,
    "logo": logo,
    "ronda": ronda.toJson(),
  };
}

class Ronda {
  CuartosDeFinal cuartosDeFinal;
  CuartosDeFinal semifinales;
  CuartosDeFinal rondaFinal;

  Ronda({
    required this.cuartosDeFinal,
    required this.semifinales,
    required this.rondaFinal,
  });

  factory Ronda.fromJson(Map<String, dynamic> json) => Ronda(
    cuartosDeFinal: CuartosDeFinal.fromJson(json["cuartos_de_final"]),
    semifinales: CuartosDeFinal.fromJson(json["semifinales"]),
    rondaFinal: CuartosDeFinal.fromJson(json["final"]),
  );

  Map<String, dynamic> toJson() => {
    "cuartos_de_final": cuartosDeFinal.toJson(),
    "semifinales": semifinales.toJson(),
    "final": rondaFinal.toJson(),
  };
}

class CuartosDeFinal {
  List<Partido> partidos;

  CuartosDeFinal({required this.partidos});

  factory CuartosDeFinal.fromJson(Map<String, dynamic> json) => CuartosDeFinal(
    partidos: List<Partido>.from(
      json["partidos"].map((x) => Partido.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "partidos": List<dynamic>.from(partidos.map((x) => x.toJson())),
  };
}

class Partido {
  String jugador1;
  String jugador2;
  String resultado;

  Partido({
    required this.jugador1,
    required this.jugador2,
    required this.resultado,
  });

  factory Partido.fromJson(Map<String, dynamic> json) => Partido(
    jugador1: json["jugador1"],
    jugador2: json["jugador2"],
    resultado: json["resultado"],
  );

  Map<String, dynamic> toJson() => {
    "jugador1": jugador1,
    "jugador2": jugador2,
    "resultado": resultado,
  };
}
