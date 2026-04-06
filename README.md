# 🎾 ATP Tennis Scorer — Professional Tennis Umpire App

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.41-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.11-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Android](https://img.shields.io/badge/Android-Tablet%20%7C%20Mobile-3DDC84?style=for-the-badge&logo=android&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)

**A professional-grade tennis scoring app built for chair umpires at top-tier tournaments.**
Modeled after the real electronic scoreboards used at ATP Grand Slam events.

</div>

---

## 📋 Table of Contents

- [About](#-about)
- [Demo](#-demo)
- [Features](#-features)
- [App Flow](#-app-flow)
- [Tech Stack](#-tech-stack)
- [Architecture](#-architecture)
- [Getting Started](#-getting-started)
- [Project Structure](#-project-structure)
- [Backend API](#-backend-api)
- [Author](#-author)

---

## 🏆 About

**ATP Tennis Scorer** is a Flutter app designed for mobile devices and tablets in **landscape mode**, enabling professional tennis umpires to officiate a match in real time.

The UI draws directly from the electronic scoreboards seen at Grand Slam venues, down to details like:

- **ROLEX branding** (official Grand Slam timekeeper)
- **Live clock** and **match elapsed time**
- **ATP-style scoreboard**: points (0 / 15 / 30 / 40 / AD), games per set, and sets
- **Tie-break scores** displayed as superscripts (just like stadium screens)
- **Serve indicator** with a yellow triangle that rotates automatically following official rules

---

## 🎬 Demo

![App demo](assets/screenshots/Animation.gif)

---

## ✨ Features

### 🎯 Full Scoring Engine
- Official tennis scoring: `0 → 15 → 30 → 40 → Deuce → AD → Game`
- **Advantage and deuce** logic — a 2-point margin is required to win the game
- Best-of-3 sets format (first to win 2 sets takes the match)
- **Tie-break at 6-6**: first to 7 with a 2-point lead
- **Automatic serve rotation** after every game, with the correct alternating pattern during tie-breaks (1 + blocks of 2)
- **Random first serve** at match start

### 🏟️ Tournament Selection
- 4 Grand Slams available: **Australian Open, Roland Garros, Wimbledon, and US Open**
- Tournament logos fetched live from the backend
- Visual selection with a highlighted confirmation border

### 🔄 Round Selection
- **Quarterfinals, Semifinals, and Final**

### 👤 Player Selection
- Grid layout featuring top ATP-ranked players
- Official photos loaded from the API
- **Player name pronunciation** via audio on selection
- Ranking badge (`#1`, `#2`...) or crown icon 👑 for legends
- Exactly 2 players must be selected to start

### 📊 Live Scoreboard
- Match screen styled after the **official ATP scoreboard**:
  - Full name, surname, and country for each player
  - Current game point
  - Games won across all 3 sets
  - Tie-break score shown as a superscript when active
  - Animated serve indicator
- Two large **point buttons** — one per player, optimized for touch
- Automatic match-end detection

### ☁️ Backend Sync
- Once the match ends, the result can be **uploaded automatically** to the tournament database
- Results follow the official format including tie-breaks: `7-6(3), 6-4`

### 📱 Responsive Design
- Optimized for **tablets in landscape** (~1000 px width baseline)
- Scales cleanly to **any phone in landscape** via a dynamic scale factor

---

## 🔀 App Flow

```
Home
  └─► Tournament Selection
        └─► Round Selection  (Quarters / Semis / Final)
              └─► Player Selection  (+ name pronunciation audio)
                    └─► Live Match
                          └─► Match Over → Upload Result → Back to Home
```

---

## 🛠️ Tech Stack

| Technology | Purpose |
|---|---|
| [Flutter 3.41](https://flutter.dev) | UI framework |
| [Dart 3.11](https://dart.dev) | Language |
| [go_router](https://pub.dev/packages/go_router) | Declarative screen navigation |
| [just_audio](https://pub.dev/packages/just_audio) | Audio playback (player names) |
| [http](https://pub.dev/packages/http) | REST API communication |
| [google_fonts](https://pub.dev/packages/google_fonts) | Premium typefaces (EB Garamond for ROLEX styling) |
| [font_awesome_flutter](https://pub.dev/packages/font_awesome_flutter) | Vector icons (No. 1 crown) |
| [responsive_framework](https://pub.dev/packages/responsive_framework) | Additional responsive layout support |

---

## 🏗️ Architecture

The project follows a layered **MVVM-like** architecture with clear separation of concerns:

```
lib/
├── main.dart                        # Entry point
├── router/
│   └── app_router.dart              # GoRouter route definitions
├── models/                          # Data models with JSON serialization
├── services/                        # Network layer: REST API calls
└── presentation/
    ├── screens/                     # Screens (UI + local state)
    └── widgets/
        ├── tennis_game.dart         # Scoring engine (pure logic)
        └── elevated_button_widget.dart
```

### Scoring Engine — `TennisGame`

A pure-logic class that implements the full official ruleset:

| Method | Responsibility |
|---|---|
| `pointTo(PlayerSide)` | Main entry point — awards a point to P1 or P2 |
| `_pointNormal()` | Handles 0 / 15 / 30 / 40 / Deuce / AD transitions |
| `_pointTieBreak()` | Tie-break scoring with the official serve pattern |
| `_winGame()` | Updates games, rotates serve, triggers tie-break when needed |
| `_winSet()` | Advances to the next set and resets counters |
| `getPointText()` | Returns the current point as display text |

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) ≥ 3.41
- Android SDK with **Build-Tools 35** installed
- Android device or emulator in **landscape mode**

### Setup

```bash
# 1. Clone the repository
git clone https://github.com/DanielMVenzala/marcador_tenis_flutter.git
cd marcador_tenis_flutter

# 2. Install dependencies
flutter pub get

# 3. Run on a connected device
flutter run
```

> **Note:** The app requires an internet connection to fetch tournament and player data from the API, and to upload match results.

---

## 📁 Project Structure

```
marcador_tenis/
├── android/                         # Android platform config
├── assets/
│   ├── audio/                       # MP3s: player name pronunciations
│   ├── fonts/                       # BebasNeue-Regular.ttf
│   └── images/                      # ATP, ROLEX, tournament & player logos
├── database/
│   └── players/players.json         # Local ATP player dataset
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

## 🌐 Backend API

The app consumes two custom REST APIs hosted on Render:

| Endpoint | Method | Description |
|---|---|---|
| `/api/v1/jugadores` | `GET` | Player list with photos, rankings, and audio references |
| `/api/v1/torneos` | `GET` | Tournament list with names, logos, and results by round |
| `/api/v1/torneos` | `POST` | Uploads a completed match result to the tournament |

---

## 👤 Author

**Daniel** — Final-year project, Cross-Platform Application Development (DAM)

---

<div align="center">
  <sub>Built with Flutter · Inspired by the official ATP Tour scoreboards</sub>
</div>
