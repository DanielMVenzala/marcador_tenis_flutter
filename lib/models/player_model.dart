class Player {
  String id;
  String nombre;
  int edad;
  int ranking;
  String pais;
  String foto;
  String audioRef;
  String apellidos;

  Player({
    required this.id,
    required this.nombre,
    required this.edad,
    required this.ranking,
    required this.pais,
    required this.foto,
    required this.audioRef,
    required this.apellidos,
  });

  factory Player.fromJson(Map<String, dynamic> json) => Player(
    id: json["_id"],
    nombre: json["nombre"],
    edad: json["edad"],
    ranking: json["ranking"],
    pais: json["pais"],
    foto: json["foto"],
    audioRef: json["audioRef"],
    apellidos: json["apellidos"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "nombre": nombre,
    "edad": edad,
    "ranking": ranking,
    "pais": pais,
    "foto": foto,
    "audioRef": audioRef,
    "apellidos": apellidos,
  };
}
