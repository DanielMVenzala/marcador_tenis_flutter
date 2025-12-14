import 'package:flutter/material.dart';
import 'package:marcador_tenis/presentation/widgets/elevated_button_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF08145c),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/atpLogo.png', width: 400),

            SizedBox(height: 40),

            ElevatedButtonWidget(
              enabled: true,
              route: '/tournamentSelection',
              text: 'Comenzar',
            ),
          ],
        ),
      ),
    );
  }
}
