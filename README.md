# 🎾 ATP Tennis Scorer — Marcador de Tenis Profesional

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.41-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.11-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Android](https://img.shields.io/badge/Android-Tablet%20%7C%20Mobile-3DDC84?style=for-the-badge&logo=android&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)

**Aplicación profesional de arbitraje de tenis diseñada para jueces de silla en torneos de primer nivel.**
Inspirada visualmente en los marcadores oficiales de los Grand Slams de la ATP.

<!-- DEMO: arrastra aquí tu GIF o vídeo una vez lo tengas grabado (ver sección Demo más abajo) -->

</div>

---

## 📋 Tabla de contenidos

- [Sobre el proyecto](#-sobre-el-proyecto)
- [Demo](#-demo)
- [Características](#-características)
- [Flujo de la aplicación](#-flujo-de-la-aplicación)
- [Tecnologías utilizadas](#-tecnologías-utilizadas)
- [Arquitectura](#-arquitectura)
- [Instalación y ejecución](#-instalación-y-ejecución)
- [Estructura del proyecto](#-estructura-del-proyecto)
- [API Backend](#-api-backend)
- [Autor](#-autor)

---

## 🏆 Sobre el proyecto

**ATP Tennis Scorer** es una aplicación Flutter orientada a dispositivos móviles y tablets en **modo horizontal** que permite a un árbitro profesional de tenis arbitrar un partido en tiempo real.

La interfaz está inspirada en los marcadores electrónicos reales de los Grand Slams, con detalles como:

- **Branding ROLEX** (patrocinador oficial del tiempo en los Grand Slams)
- **Reloj en tiempo real** y **cronómetro del partido**
- **Marcador oficial ATP**: puntos (0 / 15 / 30 / 40 / AD), juegos por set y sets
- **Tie-break** con puntuación parcial visible en superíndice (estilo pantallas de estadio)
- **Indicador de saque** con triángulo amarillo y rotación automática según el reglamento

---

## 🎬 Demo

![Demo de la app](assets/screenshots/Animation.gif)

---

## ✨ Características

### 🎯 Lógica de arbitraje completa
- Puntuación oficial de tenis: `0 → 15 → 30 → 40 → Deuce → AD → Juego`
- **Ventaja y deuce**: mínimo 2 puntos de diferencia para ganar el juego
- Partidos al **mejor de 3 sets** (primero en ganar 2 sets)
- **Tie-break a 6-6**: primero en llegar a 7 con diferencia de 2 puntos
- **Rotación de saque** automática: tras cada juego y con patrón oficial en el tie-break (1 + bloques de 2)
- Saque inicial **aleatorio** al comenzar el partido

### 🏟️ Selección de torneo
- 4 Grand Slams disponibles: **Australian Open, Roland Garros, Wimbledon y US Open**
- Logos cargados en tiempo real desde el backend
- Selección visual con borde de confirmación

### 🔄 Selección de ronda
- **Cuartos de final, Semifinal y Final**

### 👤 Selección de jugadores
- Cuadrícula con los mejores jugadores del ranking ATP
- Fotos oficiales cargadas desde la API
- **Pronunciación del nombre** del jugador mediante audio al seleccionarlo
- Indicador de ranking (`#1`, `#2`...) o corona 👑 para leyendas
- Selección limitada a exactamente 2 jugadores

### 📊 Marcador en vivo
- Pantalla estilo **marcador oficial ATP** con:
  - Nombre, apellidos y país de cada jugador
  - Puntos actuales del juego en curso
  - Juegos ganados en cada uno de los 3 sets
  - Puntuación del tie-break en superíndice cuando aplica
  - Indicador de saque animado
- Dos **botones de punto** táctiles para cada jugador
- Detección automática de fin de partido

### ☁️ Sincronización con backend
- Al finalizar el partido, el resultado se puede **subir automáticamente** a la base de datos del torneo
- Formato oficial con tie-breaks: `7-6(3), 6-4`

### 📱 Diseño responsive
- Optimizado para **tablet en horizontal** (referencia ~1000 px de ancho)
- Adaptado a cualquier **teléfono móvil en horizontal** mediante factor de escala dinámico

---

## 🔀 Flujo de la aplicación

```
Inicio
  └─► Selección de Grand Slam
        └─► Selección de ronda  (Cuartos / Semis / Final)
              └─► Selección de 2 jugadores  (+ audio de pronunciación)
                    └─► Partido en vivo
                          └─► Fin del partido → Subir resultado → Volver al inicio
```

---

## 🛠️ Tecnologías utilizadas

| Tecnología | Uso |
|---|---|
| [Flutter 3.41](https://flutter.dev) | Framework principal |
| [Dart 3.11](https://dart.dev) | Lenguaje de programación |
| [go_router](https://pub.dev/packages/go_router) | Navegación declarativa entre pantallas |
| [just_audio](https://pub.dev/packages/just_audio) | Reproducción de audio (nombres de jugadores) |
| [http](https://pub.dev/packages/http) | Comunicación con la API REST |
| [google_fonts](https://pub.dev/packages/google_fonts) | Tipografías premium (EB Garamond para ROLEX) |
| [font_awesome_flutter](https://pub.dev/packages/font_awesome_flutter) | Iconos vectoriales (corona del nº 1) |
| [responsive_framework](https://pub.dev/packages/responsive_framework) | Soporte responsivo adicional |

---

## 🏗️ Arquitectura

El proyecto sigue una arquitectura en capas similar a **MVVM**, con separación clara de responsabilidades:

```
lib/
├── main.dart                        # Punto de entrada
├── router/
│   └── app_router.dart              # Rutas con GoRouter
├── models/                          # Modelos de datos con serialización JSON
├── services/                        # Capa de red: llamadas a la API REST
└── presentation/
    ├── screens/                     # Pantallas (UI + estado local)
    └── widgets/
        ├── tennis_game.dart         # Motor de puntuación (lógica pura)
        └── elevated_button_widget.dart
```

### Motor de puntuación — `TennisGame`

Clase de lógica pura que implementa el reglamento oficial:

| Método | Responsabilidad |
|---|---|
| `pointTo(PlayerSide)` | Entrada principal: punto a P1 o P2 |
| `_pointNormal()` | Gestión de 0 / 15 / 30 / 40 / Deuce / AD |
| `_pointTieBreak()` | Puntuación del tie-break con patrón de saque oficial |
| `_winGame()` | Actualiza juegos, rota saque, detecta tie-break |
| `_winSet()` | Avanza al siguiente set y reinicia contadores |
| `getPointText()` | Representación visual del marcador de puntos |

---

## 🚀 Instalación y ejecución

### Requisitos previos

- [Flutter SDK](https://flutter.dev/docs/get-started/install) ≥ 3.41
- Android SDK con **Build-Tools 35** instalado
- Dispositivo o emulador Android en **modo landscape**

### Pasos

```bash
# 1. Clona el repositorio
git clone https://github.com/DanielMVenzala/marcador_tenis_flutter.git
cd marcador_tenis_flutter

# 2. Instala las dependencias
flutter pub get

# 3. Ejecuta en dispositivo conectado
flutter run
```

> **Nota:** La app requiere conexión a Internet para cargar los datos de torneos y jugadores, y para subir resultados al backend.

---

## 📁 Estructura del proyecto

```
marcador_tenis/
├── android/                         # Configuración Android
├── assets/
│   ├── audio/                       # MP3: pronunciación de nombres de jugadores
│   ├── fonts/                       # BebasNeue-Regular.ttf
│   └── images/                      # Logos ATP, ROLEX, torneos y jugadores
├── database/
│   └── players/players.json         # Dataset local de jugadores ATP
├── lib/
│   ├── main.dart
│   ├── models/
│   │   ├── player_model.dart
│   │   ├── player_response_model.dart
│   │   ├── tournament_model.dart
│   │   └── tournament_response_model.dart
│   ├── presentation/
│   │   ├── screens/
│   │   │   ├── home_page.dart
│   │   │   ├── tournament_selection_page.dart
│   │   │   ├── round_selection_page.dart
│   │   │   ├── player_selection_page.dart
│   │   │   └── game_page.dart
│   │   └── widgets/
│   │       ├── elevated_button_widget.dart
│   │       └── tennis_game.dart
│   ├── router/
│   │   └── app_router.dart
│   └── services/
│       ├── player_service.dart
│       └── tournament_service.dart
└── pubspec.yaml
```

---

## 🌐 API Backend

La app consume dos APIs REST propias alojadas en Render:

| Endpoint | Método | Descripción |
|---|---|---|
| `/api/v1/jugadores` | `GET` | Lista de jugadores con foto, ranking y referencia de audio |
| `/api/v1/torneos` | `GET` | Lista de torneos con nombre, logo y resultados por ronda |
| `/api/v1/torneos` | `POST` | Sube el resultado de un partido finalizado al torneo |

---

## 👤 Autor

**Daniel** — Proyecto de fin de ciclo DAM (Desarrollo de Aplicaciones Multiplataforma)

---

<div align="center">
  <sub>Construido con Flutter · Inspirado en los marcadores oficiales de la ATP Tour</sub>
</div>
