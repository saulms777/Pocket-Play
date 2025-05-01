import 'package:flutter/material.dart';

class ChessGame extends StatefulWidget {
  const ChessGame({super.key});

  @override
  State<StatefulWidget> createState() => _ChessGameState();
}

class _ChessGameState extends State<ChessGame> {
  bool _initialized = false;
  late double _screenWidth;
  late double _screenHeight;
  late int _tileSize;

  void _initialize(BuildContext context) {
    _initialized = true;
    _screenWidth = MediaQuery.of(context).size.width;
    _screenHeight = MediaQuery.of(context).size.height;
    _tileSize = (_screenWidth - 20) ~/ 8;
  }

  void _onClick(double x, double y) {

  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) _initialize(context);
    return Scaffold(
      body: Listener(
        onPointerDown: (PointerDownEvent event) =>
            _onClick(event.localPosition.dx, event.localPosition.dy),
        child: Stack(
          children: [
            // Chess board
            Container(
              alignment: Alignment.center,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                    width: 1,
                  ),
                ),
                child: SizedBox(
                  width: _tileSize * 8,
                  height: _tileSize * 8,
                  child: GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8,
                    ),
                    itemCount: 64,
                    itemBuilder: (context, index) {
                      final isDark = (index % 8 + index ~/ 8) % 2 == 1;
                      return Container(color: isDark ? Colors.green : Colors.white);
                    },
                  ),
                ),
              ),
            ),

            // Back button
            Container(
              alignment: Alignment.topLeft,
              child: IconButton(
                onPressed: () => Navigator.pushNamed(context, 'home'),
                icon: const Icon(
                  Icons.arrow_back,
                  size: 24,
                  color: Colors.black,
                ),
              )
            ),
          ],
        ),
      ),
    );
  }

}