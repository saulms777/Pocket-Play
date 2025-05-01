import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Pocket Play'),
        automaticallyImplyLeading: false,
      ),
      body: CustomScrollView(
        primary: false,
        slivers: <Widget>[
          SliverGrid.count(
            crossAxisCount: 2,
            children: <Widget>[
              // Pong
              InkWell(
                onTap: () => Navigator.pushNamed(context, 'pong'),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Image.asset('assets/images/pong_icon.png'),
                ),
              ),

              // Chess
              InkWell(
                onTap: () => Navigator.pushNamed(context, 'chess'),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Image.asset('assets/images/chess_icon.png'),
                ),
              ),
            ],
          ),
        ]
      ),
    );
  }
}