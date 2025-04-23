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
      ),
      body: CustomScrollView(
        primary: false,
        slivers: <Widget>[
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverGrid.count(
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}