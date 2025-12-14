import 'package:flutter/material.dart';

import 'router/app_router.dart';

void main() {
  //Para poner la barra superior clara

  // WidgetsFlutterBinding.ensureInitialized();

  // SystemChrome.setSystemUIOverlayStyle(
  //   const SystemUiOverlayStyle(
  //     statusBarColor: Colors.white, // Fondo de la barra
  //     statusBarIconBrightness: Brightness.dark, // Iconos oscuros
  //     statusBarBrightness: Brightness.light, // Para iOS
  //   ),
  // );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
