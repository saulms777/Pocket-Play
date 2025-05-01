import 'package:flutter/material.dart';

import 'home_page.dart';
import 'games/library.dart';

void main() => runApp(const MainApplication());

class MainApplication extends StatelessWidget {
  const MainApplication({super.key});

  // Application root
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pocket Play',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.orangeAccent,
        ),
      ),
      initialRoute: 'home',
      routes: {
        'home': (context) => HomePage(),
        'pong': (context) => PongGame(),
        'chess': (context) => ChessGame(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}